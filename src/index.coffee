###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

'use strict'

express = require("express")
resource = require 'express-resource'
app = express()
chalk = require "chalk"
path = require "path"
bodyParser = require "body-parser"
router = require "./router"

session = require "express-session"
app.use session
  secret: 'keyboard cat'
  resave: false
  saveUninitialized: false


exports.main = ->

  # connect to database
  exports.connectToDB()

  # include all the required middleware
  exports.middleware app

  router.http app
  server = router.websocket app

  # listen for requests
  PORT = process.env.PORT or 8000
  server.listen PORT, ->
    console.log chalk.blue "-> :#{PORT}"

exports.middleware = (app) ->
  # serve static assets
  app.use require("express-static") path.join(__dirname, '../public')

  # json body parser
  app.use bodyParser.json()


exports.connectToDB = (cb) ->
  require("./db") process.env.MONGOLAB_URI or process.env.db or "mongodb://bag:bag@ds047602.mongolab.com:47602/bag-dev", cb


if require.main is module
  exports.main()
