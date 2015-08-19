###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

mongoose = require 'mongoose'

store = mongoose.Schema
  name: String
  desc: String
  tags: Array
  website: String

store.set 'versionKey', false

module.exports = mongoose.model 'Store', store

