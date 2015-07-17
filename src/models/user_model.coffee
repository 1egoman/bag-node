###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

mongoose = require 'mongoose'

user = mongoose.Schema
  name: String
  email: String
  token: String

module.exports = mongoose.model 'user', user
