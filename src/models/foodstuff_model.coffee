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
  image: String

  checked: Boolean
  user: String
  price: String
  verified: Boolean

  stores: Object

  private: Boolean

foodstuff.set 'versionKey', false

module.exports = mongoose.model 'foodstuff', foodstuff
