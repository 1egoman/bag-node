###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

bag_ctrl = require "./controllers/bag_controller"
list_ctrl = require "./controllers/list_controller"
foodstuff_ctrl = require "./controllers/foodstuff_controller"
user_ctrl = require "./controllers/user_controller"
tags_ctrl = require "./controllers/tags_controller"
auth_ctrl = require "./controllers/auth_controller"
chalk = require "chalk"


# this object maps all routes to their respective methods
# for example:
# a record of name: 
#               routes: ['a', 'b']
#               controller: name_ctrl
# would map to something like:
# socket.on "name:a", (data) ->
#   name_ctrl.a *request stuff*, (data) ->
#     socket.emit "name:a:callback", data
exports.routes = routes =
  tags:
    controller: tags_ctrl
    routes: ["index"]

  user:
    controller: user_ctrl
    routes: ["fav", "un_fav", "show"]


  bag:
    controller: bag_ctrl
    routes: ["index", "show", "create", "update", "delete"]

  list:
    controller: list_ctrl
    routes: ["index", "show", "create", "update", "delete"]

  foodstuff:
    controller: foodstuff_ctrl
    routes: ["index", "show", "create", "update", "delete"]

exports.websocket = (app) ->

  server = require('http').createServer app
  io = require('socket.io') server


  # handshake socket
  io.of("handshake").on "connection", (socket) ->

    # exchange user information for token and user id
    socket.on "login", (data) ->
      console.log chalk.yellow("--> hnd"), data
      auth_ctrl.handshake
        body: data
        type: 'ws'
      , send: (payload) ->
        socket.emit "login:callback", payload
        console.log chalk.yellow("<-- hnd"), payload

    # onboard a new user
    socket.on "user:create", (data) ->
      console.log chalk.green("--> ws"), "user:create", data
      user_ctrl.create
        body: data
        type: 'ws'
      , send: (payload) ->
        socket.emit "user:create:callback", payload
        console.log chalk.green("<-- ws"), "user:create:callback", payload

        # the user just completed the handshake, why do they still need this?
        # this is needed so the client doesn't cache that the conenction is
        # still open (at least that's my guess)
        if payload.status.indexOf("success") isnt -1
          socket.disconnect()

    # check if a username is unique
    socket.on "user:unique", (data) ->
      console.log chalk.green("--> ws"), "user:unique", data
      user_ctrl.unique
        body: data
        type: 'ws'
      , send: (payload) ->
        socket.emit "user:unique:callback", payload
        console.log chalk.green("<-- ws"), "user:unique:callback", payload


  io.use (socket, next) ->
    token = socket.request?._query?.token
    if token
      user_ctrl.is_token_valid token, (valid) ->
        if valid is true
          socket.has_perms = true
          next()
        else
          next new Error "not authorized"
    else
      # user isn't authorized, which in some cases is ok
      # let's just remember this, though
      socket.has_perms = false
      next()

  # iterate for each user
  user_ctrl.index {}, send: (users) ->
    for user in users.data
      io.of(user._id).on "connection", (socket) ->

        # we need to be authorized!!!
        if socket.has_perms is false
          return socket.emit "permissiondenied"


        # iterate through routes
        for k, v of exports.routes
          for method in v.routes

            # wrap in closure so loop doesn't "outpace" the current scope
            do (k, v, method) ->
              socket.on "#{k}:#{method}", (data) ->
                data or= {}

                # log the request happening
                console.log chalk.green("--> ws"), "#{k}:#{method}", data

                # extract params
                params = {}
                params[k] = data[k]

                v.controller[method]
                  body: data
                  type: 'ws'
                  params: params
                  user: user
                ,
                  send: (data) ->
                    # log the event response
                    console.log \
                      chalk.green("<-- ws"), \
                      "#{k}:#{method}:callback", \
                      JSON.stringify data, null, 2

                    # let everyone know
                    if method in ["create", "update", "destroy"]
                      socket.broadcast.emit "#{k}:#{method}:callback", data
                    socket.emit "#{k}:#{method}:callback", data

  server

# TODO un half-ass this....
exports.http = (app) ->
  app.resource "lists", list_ctrl
  app.resource "foodstuffs", foodstuff_ctrl
