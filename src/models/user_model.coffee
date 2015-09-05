###
#
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

mongoose = require 'mongoose'

user = mongoose.Schema
  realname: String
  name: String
  email: String
  password: String
  salt: String

  token: String
  favs: Array
  stores: Array

  clicks: Array


  plan: Number
  plan_expire: Number
  stripe_id: String

module.exports = mongoose.model 'user', user
