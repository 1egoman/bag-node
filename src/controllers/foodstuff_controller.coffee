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
  query = Foodstuff.find
    $or: [
      private: false
    ,
      user: req.user._id
      private: true
    ]
  .sort date: -1

  # limit quantity and a start index
  query = query.skip parseInt req.body.start if req.body?.start
  query = query.limit parseInt req.body.limit if req.body?.limit
  
  # limit by user
  if req.body?.user
    if req.body.user is "me"
      query = query.find user: req.user._id
    else
      query = query.find user: req.body.user

  query.exec (err, data) ->
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
  foodstuff_params = req.body?.foodstuff

  # verify the foodstuff
  if foodstuff_params and \
    foodstuff_params.name? and \
    foodstuff_params.desc? and \
    foodstuff_params.price? and \
    foodstuff_params.tags?
      foodstuff_params.user = req.user._id if req.user?._id

      # if the foodstuff is public, make it unverified
      foodstuff_params.verified = false

      # private recipe
      if foodstuff_params.private and req.user.plan > 0
        foodstuff_params.private = true
        
        # format the price with a custom store
        foodstuff_params.stores = custom: price: foodstuff_params.price

      # unpaid users cannot make private recipes
      else
        foodstuff_params.private = false

      # create the foodstuff
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


# search for a foodstuff using the given search query (req.params.foodstuff)
exports.search = (req, res) ->
  Foodstuff.find
    $or: [
      private: false
      name: $regex: new RegExp req.params.foodstuff, 'i'
    ,
      user: req.user._id
      private: true
      name: $regex: new RegExp req.params.foodstuff, 'i'
    ]
  , (err, data) ->
    if err
      res.send
        status: "bag.error.foodstuff.search"
        error: err
    else
      res.send
        status: "bag.success.foodstuff.search"
        data: data

