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
  query = Store.find(verified: true).sort date: -1

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


# suggest a new store to be created.
exports.suggest = (req, res) ->
  store = req.body
  console.log 1, store

  if store.name and store.item and store.item_price and store.item_brand
    console.log 2

    store.verified = false
    store.tags = []
    console.log 3, Store

    new Store store
    # .save (err) ->
    #   console.log 4
    #   if err
    #     res.send
    #       name: "bag.error.store.suggest"
    #       err: err
    #
    #   else
    #     res.send
    #       name: "bag.success.store.suggest"

  else
    res.send
      name: "bag.error.store.suggest"
      err: "Invalid arguments."
