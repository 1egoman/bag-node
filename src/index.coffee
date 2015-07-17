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


exports.main = ->

  # connect to database
  exports.connectToDB()

  # include all the required middleware
  exports.middleware app

  # some sample routes
  app.get "/", (req, res) ->
    res.send "'Allo, World!"

  router.http app
  server = router.websocket app

  # listen for requests
  PORT = process.argv.port or 8000
  server.listen PORT, ->
    console.log chalk.blue "-> :#{PORT}"

exports.middleware = (app) ->
  # serve static assets
  app.use require("express-static") path.join(__dirname, '../public')

  # json body parser
  app.use bodyParser.json()


exports.connectToDB = ->
  require("./db") module.exports.mongouri or module.exports.db or "mongodb://bag:bag@ds047602.mongolab.com:47602/bag-dev"


exports.main()
