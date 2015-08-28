###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
uuid = require "uuid"
List = require "../models/list_model"

# get a list of all lists
# GET /list
exports.index = (req, res) ->
  query = List.find({}).sort date: -1

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
        status: "bag.error.list.index"
        error: err
    else
      res.send
        status: "bag.success.list.index"
        data: data

exports.new = (req, res) -> res.send "Not supported."

# create a new list
# POST /list
exports.create = (req, res) ->
  list_params = req.body?.list
  if list_params and \
  list_params.name? and \
  list_params.desc? and \
  list_params.contents? and \
  list_params.tags?
    list_params.user = req.user._id if req.user?._id
    list = new List list_params
    list.save (err) ->
      if err
        res.send
          status: "bag.error.list.create"
          error: err
      else
        res.send
          status: "bag.success.list.create"
          data: list
  else
    res.send
      status: "bag.error.list.create"
      error: "all the required elements weren't there."

# get a list with the specified id
# GET /list/:list
exports.show = (req, res) ->
  List.findOne _id: req.params.list, (err, data) ->
    if err
      res.send
        status: "bag.error.list.show"
        error: err
    else
      res.send
        status: "bag.success.list.show"
        data: data

exports.edit = (req, res) -> res.send "Not supported."

# update a list
# PUT /list/:list
exports.update = (req, res) ->
  List.findOne _id: req.params.list or req.body._id, (err, data) ->
    if err
      res.send
        status: "bag.error.list.update"
        error: err
    else
      data[k] = v for k, v of req.body?.list
      data.save (err) ->
        if err
          res.send
            status: "bag.error.list.update"
            data: err
            all: req.body?.list
        else
        # List.find {}, (err, all) ->
          res.send
            status: "bag.success.list.update"
            data: data
            # all: all

# delete a list
# DELETE /list/:list
exports.destroy = (req, res) ->
  List.remove _id: req.params.list, (err, data) ->
    if err
      res.send
        status: "bag.error.list.delete"
        error: err
    else
      res.send
        status: "bag.success.list.delete"



# search for a foodstuff using the given search query (req.params.foodstuff)
exports.search = (req, res) ->
  List.findOne
    name:
      $contains: req.params.list
  , (err, data) ->
    if err
      res.send
        status: "bag.error.list.search"
        error: err
    else
      res.send
        status: "bag.success.list.search"
        data: data

