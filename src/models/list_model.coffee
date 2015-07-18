###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

mongoose = require 'mongoose'

list = mongoose.Schema
  name: String
  desc: String
  tags: Array
  checked: Boolean
  user: String

  contents: Array

list.set('versionKey', false)

module.exports = mongoose.model 'List', list

