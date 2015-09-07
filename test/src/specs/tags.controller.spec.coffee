'use strict'
require "./spec_helper.spec"
Tag = require "../../../src/controllers/tags_controller"

# environment-specific config
USER_ID = process.env.USER_ID or "55d3b333e2bf182b637341dc" # my user id (rgausnet)

describe "tag queries", ->


  # bag:index
  # get all tags
  describe "tag:index", ->
    it "tag:index returns info with valid user id", (done) ->
      Tag.index
        user: _id: USER_ID
      ,
        send: (data) ->
          data.should.not.be.null
          data.status.should.contain "success"
          data.data.should.be.an.array
          done()

  # bag:update
  # update the bag for a specific user
  describe "tag:show", ->
    it "tag:show will get all tags with the specified phrase", (done) ->

      # update the bag
      Tag.show
        params:
          tag: "veg"
      ,
        send: (data) ->
          data.should.not.be.null
          data.status.should.contain "success"
          data.data.should.be.an.array

          data.data.should.contain "vegetarian"
          data.data.should.contain "vegan"

          done()

    for phrase in [
      "bad user id"
      null
      0
      5
      undefined
      "<% console.log(1) %>"
    ]
      it "bag:update returns null data with bad user id that is '#{phrase}'", (done) ->
        Tag.show
          params:
            tag: phrase
        ,
          send: (data) ->
            data.should.not.be.null
            data.status.should.contain "error"
            done()
