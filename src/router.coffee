###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

list_ctrl = require "./controllers/list_controller"
foodstuff_ctrl = require "./controllers/foodstuff_controller"
user_ctrl = require "./controllers/user_controller"
chalk = require "chalk"

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

        # websocket events for each of the actions
        ["index", "show", "create", "update", "destroy"].forEach (method) ->
          
          # list methods
          socket.on "list:#{method}", (data) ->

            # log the request happening
            console.log chalk.green("--> ws"), "list:#{method}", data

            list_ctrl[method]
              body: data
              type: 'ws'
              params:
                list: data.list
            ,
              send: (data) ->
                # log the event response
                console.log \
                  chalk.green("<-- ws"), \
                  "list:#{method}:callback", \
                  JSON.stringify data, null, 2
                socket.emit "list:#{method}:callback", data

          # foodstuff methods
          socket.on "foodstuff:#{method}", (data) ->

            # log the request happening
            console.log chalk.green("--> ws"), "list:#{method}", data

            foodstuff_ctrl[method]
              body: data
              type: 'ws'
              params:
                list: data.list
            ,
              send: (data) ->
                # log the event response
                console.log \
                  chalk.green("<-- ws"), \
                  "foodstuff:#{method}:callback", \
                  JSON.stringify data, null, 2
                socket.emit "foodstuff:#{method}:callback", data


  server

exports.http = (app) ->
  app.resource "lists", list_ctrl
  app.resource "foodstuffs", foodstuff_ctrl
