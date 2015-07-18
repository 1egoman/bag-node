###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

mongoose = require 'mongoose'

bag = mongoose.Schema
  user: String

  contents: Array
  contentsLists: [
    _id:
      type: String
      ref: 'List'
  ]

bag.set 'versionKey', false

module.exports = mongoose.model 'Bag', bag

