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
  List.find {}, (err, data) ->
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
    list_params.price? and \
    list_params.store? and \
    list_params.tags?
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
  List.findOne _id: req.params.list, (err, data) ->
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
        else
          res.send
            status: "bag.success.list.update"
            data: data

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
