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
  user: String

  contents: Array

module.exports = mongoose.model 'List', list

