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
  tags: Array
  checked: Boolean
  user: String
  price: String
  verified: Boolean

  stores: Object


module.exports = mongoose.model 'foodstuff', foodstuff
