###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
uuid = require "uuid"
Foodstuff = require "../models/foodstuff_model"

# get a foodstuff of all lists
# GET /foodstuff
exports.index = (req, res) ->

  Foodstuff.find({}).limit(req?.body?.limit || Infinity).exec (err, data) ->
    if err
      res.send
        status: "bag.error.foodstuff.index"
        error: err
    else
      res.send
        status: "bag.success.foodstuff.index"
        data: data

exports.new = (req, res) -> res.send "Not supported."

# create a new foodstuff
# POST /foodstuff
exports.create = (req, res) ->
  foodstuff_params = req.body?.list
  if foodstuff_params and \
    foodstuff_params.name? and \
    foodstuff_params.desc? and \
    foodstuff_params.price? and \
    foodstuff_params.store? and \
    foodstuff_params.tags?
      foodstuff_params.user = req.user._id if req.user?._id
      foodstuff = new Foodstuff foodstuff_params
      foodstuff.save (err) ->
        if err
          res.send
            status: "bag.error.foodstuff.create"
            error: err
        else
          res.send
            status: "bag.success.foodstuff.create"
            data: foodstuff
  else
    res.send
      status: "bag.error.foodstuff.create"
      error: "all the required elements weren't there."

# get a foodstuff with the specified id
# GET /foodstuff/:list
exports.show = (req, res) ->
  Foodstuff.findOne _id: req.params.foodstuff, (err, data) ->
    if err
      res.send
        status: "bag.error.foodstuff.show"
        error: err
    else
      res.send
        status: "bag.success.foodstuff.show"
        data: data

exports.edit = (req, res) -> res.send "Not supported."

# update a foodstuff
# PUT /foodstuff/:list
exports.update = (req, res) ->
  Foodstuff.findOne _id: req.params.foodstuff, (err, data) ->
    if err
      res.send
        status: "bag.error.foodstuff.update"
        error: err
    else
      data[k] = v for k, v of req.body?.foodstuff
      data.save (err) ->
        if err
          res.send
            status: "bag.error.foodstuff.update"
            data: err
        else
          res.send
            status: "bag.success.foodstuff.update"
            data: data

# delete a foodstuff
# DELETE /foodstuff/:list
exports.destroy = (req, res) ->
  Foodstuff.remove _id: req.params.foodstuff, (err, data) ->
    if err
      res.send
        status: "bag.error.foodstuff.delete"
        error: err
    else
      res.send
        status: "bag.success.foodstuff.delete"
