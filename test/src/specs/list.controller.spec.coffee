'use strict'
require "./spec_helper.spec"
List = require "../../../src/controllers/list_controller"

# environment-specific config
USER_ID = process.env.USER_ID or "55d3b333e2bf182b637341dc" # my user id (rgausnet)

describe "list queries", ->
  test_list = null


  # list:index
  # get the bag for the specified user
  describe "list:index", ->
    it "list:index returns info with valid user id", (done) ->
      List.index
        body:
          start: 0
          limit: 25
      ,
        send: (data) ->
          data.should.not.be.null
          data.status.should.contain "success"
          data.data.should.be.an.object

          data.data.should.be.an.array
          data.data.length.should.be.lte 25

          done()

    it "list:index returns only my items with user: 'me'", (done) ->
      List.index
        body:
          user: 'me'
          start: 0
          limit: 25
        user: _id: USER_ID
      ,
        send: (data) ->
          data.should.not.be.null
          data.status.should.contain "success"

          data.data.should.be.an.array
          data.data.length.should.be.lte 25

          # we own all of the items returned
          data.data.filter (n) ->
            n.user isnt USER_ID
          .should.be.empty

          test_list = data.data[0] # pick a list to modify
          done()


  # list:update
  # update the list for a specific user
  describe "list:update", ->
    it "list:update will update a valid list", (done) ->

      # update the list
      test_list.name += "[CHANGE]"

      # update the bag
      List.update
        params: list: test_list._id
        body: test_list
      ,
        send: (data) ->
          data.should.not.be.null
          data.status.should.contain "success"
          data.data.should.be.an.object

          # data information
          data.data.should.be.an.object
          data.data.name.should.be.a.string
          data.data._id.toString().should.equal test_list._id.toString()

          done()

    for cnts in [
      "bad user id"
      null
      0
      5
      undefined
      "<% console.log(1) %>"
    ]
      it "list:update returns null data with bad user id / list id that is '#{cnts}'", (done) ->
        List.update
          params: list: cnts
          body: list: cnts
        ,
          send: (data) ->
            data.should.not.be.null
            data.status.should.contain "error"
            done()

  # unsupported routes
  for i in [
    "new"
    "edit"
  ]
    describe "list:#{i}", ->
      it "should verify that list:#{i} doesn't do anything (should return Not supported.)", ->
        List[i] {}, send: (data) ->
          data.should.equal "Not supported."
