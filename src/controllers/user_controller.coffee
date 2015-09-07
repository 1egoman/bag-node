###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###
uuid = require "uuid"
_ = require "underscore"
bcrypt = require "bcrypt"
async = require "async"

User = require "../models/user_model"
Pick = require "../models/pick_model"
Bag = require "../models/bag_model"
Store = require "../models/store_model"

{gen_picks_for} = require "./pick_controller"

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

      async.waterfall [
        # pass in our user params object
        (cb) -> cb null, user_params

        # make sure email is really an email
        (user_params, cb) ->
          if user_params.email.match /\S+@\S+\.\S+/i
            cb null, user_params
          else
            cb "The email specified isn't an email!"

        # make sure username and email are unique
        (user_params, cb) ->
          User.findOne
            $or: [
              name: user_params.name
            ,
              email: user_params.email
            ]
          , (err, result) ->
            if err
              cb err
            else if not result
              cb null, user_params
            else
              cb "Username or email not unique"

        # hash password and create salt
        (user_params, cb) ->
          bcrypt.genSalt 10, (err, salt) ->
            if err
              res.send
                status: "bag.error.user.create"
                error: err
            else
              bcrypt.hash user_params.password, salt, (err, hash) ->
                if err
                  res.send
                    status: "bag.error.user.create"
                    error: err
                else
                  user_params.password = hash
                  user_params.salt = salt
                  cb null, user_params

        # generate request token
        (user_params, cb) ->
          user_params.token = do (token_len=128) ->
            [0..token_len].map ->
              String.fromCharCode(_.random(65, 95))
            .join ''
          cb null, user_params

        # set plan = 0
        (user_params, cb) ->
          user_params.plan = 0
          cb null, user_params

        # if no stores were saved, just inject one to start with.
        # new users start with whole foods, by default
        (user_params, cb) ->
          if user_params.stores
            cb null, user_params
          else
            Store.findOne name: "Whole Foods", (err, item) ->
              if not err and item
                user_params.stores = [ item._id ]
              cb null, user_params

        # create user model and save it
        (user_params, cb) ->
          user = new User user_params
          user.save (err) ->
            if err
              res.send
                status: "bag.error.user.create"
                error: err
            else

              # generate a bag, too
              bag = new Bag user: user._id
              bag.save (err) ->
                if err
                  res.send
                    status: "bag.error.user.create"
                    error: err
                else
                  # and, generate a picks list....
                  picks = new Pick user: user._id
                  picks.save (err) ->
                    if err
                      res.send
                        status: "bag.error.user.create"
                        error: err
                    else
                      res.send
                        status: "bag.success.user.create"
                        data: user
      ], (err) ->
        if err
          res.send
            status: "bag.error.user.create"
            error: err



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
        # regenerate picks
        gen_picks_for data, (err) ->
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
      if err
        res.send
          status: "bag.error.user.unfavorite"
          error: err
      else
        # regenerate picks
        gen_picks_for data, (err) ->
          if err
            res.send
              status: "bag.error.user.unfavorite"
              error: err
          else
            res.send
              status: "bag.success.user.unfavorite"



# check if a username is unique
exports.unique = (req, res) ->

 # length of zero? That cannot be a username.....
  if req.body.user.length is 0
    return res.send status: "bag.success.user.dirty"

  User.findOne name: req.body.user, (err, result) ->
    if err or not result
      res.send status: "bag.success.user.clean"
    else
      res.send status: "bag.success.user.dirty"


# using the req body, post an update to the stores for a user
exports.updatestores = (req, res) ->
  query = User.findOne _id: req.user._id
  query.exec (err, data) ->
    data.stores = req.body.stores

    # save it
    data.save (err) ->
      if err
        res.send
          status: "bag.error.user.updatestores"
          error: err
      else
        res.send
          status: "bag.success.user.updatestores"

# register a click for a specific store
exports.click = (req, res) ->
  query = User.findOne _id: req.user._id
  query.exec (err, data) ->

    # add the specific id to the click array
    data.clicks or= []
    data.clicks.push
      store: req.body.recipe
      date: new Date().toJSON()

    # save it
    data.save (err) ->
      if err
        res.send
          status: "bag.error.user.click"
          error: err
      else
        # regenerate picks
        gen_picks_for data, (err) ->
          if err
            res.send
              status: "bag.error.user.click"
              error: err
          else
            res.send
              status: "bag.success.user.click"


