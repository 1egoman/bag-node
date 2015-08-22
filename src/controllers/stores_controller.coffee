###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
uuid = require "uuid"
Store = require "../models/store_model"

# get a store of all lists
# GET /store
exports.index = (req, res) ->
  query = Store.find({}).sort date: -1

  # limit quantity and a start index
  query = query.skip parseInt req.body.start if req.body?.start
  query = query.limit parseInt req.body.limit if req.body?.limit
  
  query.exec (err, data) ->
    if err
      res.send
        status: "bag.error.store.index"
        error: err
    else
      res.send
        status: "bag.success.store.index"
        data: data

exports.new = (req, res) -> res.send "Not supported."
exports.edit = (req, res) -> res.send "Not supported."
