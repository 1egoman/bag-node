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

  verified: Boolean

  # when a new item is being considered, it is stored directly into the store
  # model.
  item: String
  item_price: Number
  item_brand: String

store.set 'versionKey', false

module.exports = mongoose.model 'Store', store

