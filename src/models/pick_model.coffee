###
 * bag
 * getbag.io
 *
 * Copyright (c) 2015 Ryan Gaus
 * Licensed under the MIT license.
###

mongoose = require 'mongoose'

pick = mongoose.Schema
  user: String
  picks: Object
  blacklist: Array

pick.set 'versionKey', false

module.exports = mongoose.model 'pick', pick

