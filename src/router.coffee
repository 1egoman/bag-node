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
store_ctrl = require "./controllers/stores_controller"
chalk = require "chalk"
pjson = require "../package.json"


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
  tag:
    controller: tags_ctrl
    routes: ["index", "show"]

  user:
    controller: user_ctrl
    routes: ["fav", "un_fav", "show", "updatestores", "click"]


  bag:
    controller: bag_ctrl
    routes: ["index", "show", "create", "update", "delete", "update_store"]

  list:
    controller: list_ctrl
    routes: ["index", "show", "create", "update", "delete"]

  foodstuff:
    controller: foodstuff_ctrl
    routes: ["index", "show", "create", "update", "delete"]

  store:
    controller: store_ctrl
    routes: ["index"]

exports.websocket = (app) ->

  server = require('http').createServer app
  io = require('socket.io') server,
   'close timeout': .2
   'client store expiration': .2

  # handshake socket
  io.of("handshake").on "connection", (socket) ->
    console.log chalk.yellow "--- new handshake attempt..."

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

        # create a new user socket for that user
        initialize_user_socket io, payload.data

        # do dat logging!
        socket.emit "user:create:callback", payload
        console.log chalk.green("<-- ws"), "user:create:callback", payload

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
      initialize_user_socket io, user

  server

# create a new user socket for the specified user.
# this happens on startup for each user and for each user that is created.
initialize_user_socket = (io, user) ->
  io.of(user._id).on "connection", (socket) ->
    console.log chalk.green "--- User '#{user._id}' connected!!!!"

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


# TODO un half-ass this....
exports.http = (app) ->
  app.resource "lists", list_ctrl
  app.resource "foodstuffs", foodstuff_ctrl

  app.get "/", (req, res) ->
    res.send """
    <style>code {padding:2px 4px;font-size:90%;white-space:nowrap;background-color:#f9f2f4;border-radius:4px;color:#c7254e;}</style>
    <h1>Hello World!</h1>
    <p>This is the root of bag's server. (version <code>#{pjson.version}</code>)</p>
    <p>Nothing to see here, why not take a look at
    <a href="http://getbag.io">bag's website</a>?</p>
    """
