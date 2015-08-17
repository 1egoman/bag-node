###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
uuid = require "uuid"
_ = require "underscore"
User = require "../models/user_model"

# get a user of all lists
# GET /user
exports.index = (req, res) ->
  User.find {}, (err, data) ->
    if err
      res.send
        status: "bag.error.user.index"
        error: err
    else
      res.send
        status: "bag.success.user.index"
        data: data

exports.new = (req, res) -> res.send "Not supported."

# create a new user
# POST /user
exports.create = (req, res) ->
  user_params = req.body?.user
  if user_params and \
    user_params.realname? and \
    user_params.name? and \
    user_params.email? and \
    user_params.password?

      # hash password and create salt
      user_params.salt = do (salt_len) -> [0..salt_len].map(-> _.random(65, 95)).join ''
      console.log user_params

      user = new User user_params
      user.save (err) ->
        if err
          res.send
            status: "bag.error.user.create"
            error: err
        else
          res.send
            status: "bag.success.user.create"
            data: user
  else
    res.send
      status: "bag.error.user.create"
      error: "all the required elements weren't there."

# get a user with the specified id
# GET /user/:list
exports.show = (req, res) ->
  User.findOne _id: req.params.user, (err, data) ->
    if err
      res.send
        status: "bag.error.user.show"
        error: err
    else
      res.send
        status: "bag.success.user.show"
        data: data

exports.edit = (req, res) -> res.send "Not supported."

# update a user
# PUT /user/:list
exports.update = (req, res) ->
  User.findOne _id: req.params.user, (err, data) ->
    if err
      res.send
        status: "bag.error.user.update"
        error: err
    else
      data[k] = v for k, v of req.body?.user
      data.save (err) ->
        if err
          res.send
            status: "bag.error.user.update"
            data: err
        else
          res.send
            status: "bag.success.user.update"
            data: data

# delete a user
# DELETE /user/:list
exports.destroy = (req, res) ->
  User.remove _id: req.params.user, (err, data) ->
    if err
      res.send
        status: "bag.error.user.delete"
        error: err
    else
      res.send
        status: "bag.success.user.delete"

# is the specified token valid?
exports.is_token_valid = (token, cb) ->
  User.findOne token: token, (err, data) ->
    if data
      cb true
    else if err
      cb err
    else
      cb false


# favorite an item
# this will add the item to the favorites list inside the user model
exports.fav = (req, res) ->
  item = req.body.item

  # get a reference to the user
  query = User.findOne _id: req.user._id
  query.exec (err, data) ->

    # add item to favs list
    data.favs or= []
    data.favs.push item if item not in data.favs

    # save it
    data.save (err) ->
      if err
        res.send
          status: "bag.error.user.favorite"
          error: err
      else
        res.send
          status: "bag.success.user.favorite"




# un-favorite an item
# this will remove the item to the favorites list inside the user model
exports.un_fav = (req, res) ->
  item = req.body.item

  # get a reference to the user
  query = User.findOne _id: req.user._id
  query.exec (err, data) ->

    # add item to favs list
    data.favs or= []
    data.favs = _.without data.favs, item

    # save it
    data.save (err) ->
      console.log "ERR", err
      if err
        res.send
          status: "bag.error.user.unfavorite"
          error: err
      else
        res.send
          status: "bag.success.user.unfavorite"
