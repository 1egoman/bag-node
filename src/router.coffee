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

  io.use (socket, next) ->
    token = socket.request?._query?.token
    user_ctrl.is_token_valid token, (valid) ->
      if valid is true
        next()
      else
        next new Error "not authorized"


  # iterate for each user
  user_ctrl.index {}, send: (users) ->
    for user in users.data
      io.of(user._id).on "connection", (socket) ->


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
