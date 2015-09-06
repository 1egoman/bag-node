'use strict'
require "./spec_helper.spec"
bag = require "../../../src/controllers/bag_controller"

# environment-specific config
USER_ID = "55d3b333e2bf182b637341dc" # my user id (rgausnet)

describe "bag queries", ->



  describe "bag:index", ->

    it "bag:index returns info with valid user id", (done) ->
      bag.index
        user: _id: USER_ID
      ,
        send: (data) ->
          data.should.not.be.null
          data.status.should.contain "success"
          data.data.should.be.an.object

          # data information
          data.data.user.should.equal USER_ID
          data.data.contents.should.be.an.object
          data.data.contentsLists.should.be.an.object

          # normal contents
          if data.data.contents.length
            data.data.contents[0].should.be.an.object
            data.data.contents[0].name.should.be.a.string
            data.data.contents[0]._id.should.be.a.string

          # list contents
          if data.data.contentsLists.length
            data.data.contentsLists[0].should.be.an.object
            data.data.contentsLists[0].name.should.be.a.string
            data.data.contentsLists[0]._id.should.be.a.string

          done()

    for u_id in [
      "bad user id"
      null
      0
      5
      undefined
      "<% console.log(1) %>"
    ]
      it "bag:index returns null data with bad user id that is '#{u_id}'", (done) ->
        bag.index
          user: _id: u_id
        ,
          send: (data) ->
            data.should.not.be.null
            data.status.should.contain "success"
            (data.data is null).should.be.true

            done()

