###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

list_ctrl = require "./controllers/list_controller"
user_ctrl = require "./controllers/user_controller"

exports.websocket = (app) ->

  server = require('http').createServer app
  io = require('socket.io') server

  # iterate for each user
  user_ctrl.index {}, send: (users) ->
    for user in users.data
      io.of(user._id).on "connection", (socket) ->

        # websocket events for each of the actions
        for method in ["index", "show", "create", "update", "destroy"]
          socket.on "list:#{method}", (data) ->
            list_ctrl[method]
              body: data
              type: 'ws'
            ,
              send: (data) ->
                socket.emit "list:#{method}:callback", data


  server

exports.http = (app) ->
  app.resource "lists", require("./controllers/list_controller")
