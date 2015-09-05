###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
uuid = require "uuid"
Bag = require "../models/bag_model"

# get a bag of all lists
# GET /bag
exports.index = (req, res) ->
  Bag.findOne user: req.user._id, (err, data) ->
    if err
      res.send
        status: "bag.error.bag.index"
        error: err
    else
      res.send
        status: "bag.success.bag.index"
        data: data

exports.new = (req, res) -> res.send "Not supported."

# create a new bag
exports.create = (req, res) -> res.send "Not supported."

# get a bag with the specified id
# GET /bag/:bag
exports.show = (req, res) ->
  res.send "Not supported."
  # Bag.findOne
  #   user: req.user._id,
  #   req.params.bag
  # , (err, data) ->
  #   if err
  #     res.send
  #       status: "bag.error.bag.show"
  #       error: err
  #   else
  #     res.send
  #       status: "bag.success.bag.show"
  #       data: data

exports.edit = (req, res) -> res.send "Not supported."

# update a bag
# PUT /bag/:bag
exports.update = (req, res) ->
  Bag.findOne _id: req.params.bag or req.body._id, (err, data) ->
    console.log data
    if err or not data
      res.send
        status: "bag.error.bag.update"
        error: err
    else
      data[k] = v for k, v of req.body?.bag

      # make sure custom prices have only been used if we can.
      for i in data?.contents or []
        i.stores.custom = {} if i.store is "custom" and req.user.plan isnt 2
        i.store = "nope" if i.store is "custom" and req.user.plan isnt 2

      data.save (err) ->
        if err
          res.send
            status: "bag.error.bag.update"
            data: err
            all: req.body?.bag
        else
        # Bag.find {}, (err, all) ->
          res.send
            status: "bag.success.bag.update"
            data: data
            # all: all


# update a store within a bag
# given req.body.user, req.body.item, and req.body.store
exports.update_store = (req, res) ->
  Bag.findOne user: req.body.user, (err, data) ->
    if err
      res.send
        status: "bag.error.bag.update"
        error: err
    else
      # for each matching item (recipe's don't have stores), update the
      # store to the specified one
      data.contents.filter (i) ->
        i._id is req.body.item
      .forEach (i) ->
        i.store = req.body.store

      data.save (err) ->
        if err
          res.send
            status: "bag.error.bag.update.store"
            data: err
        else
        res.send
          status: "bag.success.bag.update.store"
          data: data


# delete a bag
# DELETE /bag/:bag
exports.destroy = (req, res) -> res.send "Not supported."
