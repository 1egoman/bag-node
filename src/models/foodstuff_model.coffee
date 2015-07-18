###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

mongoose = require 'mongoose'

foodstuff = mongoose.Schema
  name: String
  desc: String
  price: String
  store: String
  checked: Boolean
  user: String

module.exports = mongoose.model 'foodstuff', foodstuff
