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
          

          # bag methods
          socket.on "bag:#{method}", (data) ->

            # log the request happening
            console.log chalk.green("--> ws"), "bag:#{method}", data

            bag_ctrl[method]
              body: data
              type: 'ws'
              params:
                bag: data?.bag
              user: user
            ,
              send: (data) ->
                # log the event response
                console.log \
                  chalk.green("<-- ws"), \
                  "bag:#{method}:callback", \
                  JSON.stringify data, null, 2
                if method in ["create", "update", "destroy"]
                  # if we used an action of create, opdate, or destroy, let everyone know
                  socket.broadcast.emit "bag:#{method}:callback", data
                # emit it to that person
                socket.emit "bag:#{method}:callback", data





          # list methods
          socket.on "list:#{method}", (data) ->

            # log the request happening
            console.log chalk.green("--> ws"), "list:#{method}", data

            list_ctrl[method]
              body: data
              type: 'ws'
              params:
                list: data?.list
              user: user
            ,
              send: (data) ->
                # log the event response
                console.log \
                  chalk.green("<-- ws"), \
                  "list:#{method}:callback", \
                  JSON.stringify data, null, 2
                if method in ["create", "update", "destroy"]
                  # if we used an action of create, opdate, or destroy, let everyone know
                  socket.broadcast.emit "list:#{method}:callback", data
                else
                  # emit it to that person
                  socket.emit "list:#{method}:callback", data






          # foodstuff methods
          socket.on "foodstuff:#{method}", (data) ->

            # log the request happening
            console.log chalk.green("--> ws"), "list:#{method}", data

            foodstuff_ctrl[method]
              body: data
              type: 'ws'
              params:
                foodstuff: data?.foodstuff
              user: user
            ,
              send: (data) ->
                # log the event response
                console.log \
                  chalk.green("<-- ws"), \
                  "foodstuff:#{method}:callback", \
                  JSON.stringify data, null, 2

                if method in ["create", "update", "destroy"]
                  # if we used an action of create, opdate, or destroy, let everyone know
                  socket.broadcast.emit "foodstuff:#{method}:callback", data
                else
                  # emit it to that person
                  socket.emit "foodstuff:#{method}:callback", data



  server

exports.http = (app) ->
  app.resource "lists", list_ctrl
  app.resource "foodstuffs", foodstuff_ctrl
