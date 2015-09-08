'use strict'
require "./spec_helper.spec"
# Bag = require "../../../src/controllers/bag_controller"
Bag = source "controllers/bag_controller"

# environment-specific config
USER_ID = process.env.USER_ID or "55d3b333e2bf182b637341dc" # my user id (rgausnet)

describe "bag queries", ->
  bag_contents = null


  # bag:index
  # get the bag for the specified user
  describe "bag:index", ->
    it "bag:index returns info with valid user id", (done) ->
      Bag.index
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

          # set bag contents for later
          bag_contents = data.data
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
        Bag.index
          user: _id: u_id
        ,
          send: (data) ->
            data.should.not.be.null
            data.status.should.contain "error"
            (data.data is null).should.be.true

            done()


  # bag:update
  # update the bag for a specific user
  describe "bag:update", ->
    it "bag:update will update a valid bag", (done) ->

      # add a new item to the bag
      bag_contents.contents.push
        _id: "test item"
        name: "test item"
        desc: "used in tests for bag, please delete me"
        tags: []
        store: "test store"
        stores:
          "test store":
            price: 5.00

      # update the bag
      Bag.update
        params: {}
        body: bag_contents
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

    for cnts in [
      "bad user id"
      null
      0
      5
      undefined
      "<% console.log(1) %>"
    ]
      it "bag:update returns null data with bad user id that is '#{cnts}'", (done) ->
        Bag.update
          params: {}
          body: cnts
        ,
          send: (data) ->
            data.should.not.be.null
            data.status.should.contain "error"
            done()

  # bag:update_store
  # within a bag, replace every store instance with another.
  describe "bag:update_store", ->

    # TODO we should test this further to make sure the substitution happened
    it "should be able to successfully replace our test item", (done) ->
      Bag.update_store
        user:
          _id: USER_ID
          plan: 0
        body:
          item: "test item"
          store: "test store two"
      , send: (data) ->
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

    it "bad user id", (done) ->
      Bag.update_store
        user:
          _id: "bla"
          plan: 0
        body:
          item: "test item"
          store: "test store two"
      , send: (data) ->
        data.should.not.be.null
        data.status.should.contain "error"
        (data.data is null).should.be.true
        done()

    it "bad item id", (done) ->
      Bag.update_store
        user:
          _id: USER_ID
          plan: 0
        body:
          item: "I don't exist"
          store: "test store two"
      , send: (data) ->
        data.should.not.be.null
        data.status.should.contain "success" # need to figure this out FIXME
        done()

    it "bad store", (done) ->
      Bag.update_store
        user:
          _id: USER_ID
          plan: 0
        body:
          item: "test item"
          store: null # something falsey
      , send: (data) ->
        data.should.not.be.null
        data.status.should.contain "error"
        (data.data is null).should.be.true
        done()



  # unsupported routes
  for i in [
    "show"
    "new"
    "create"
    "edit"
    "destroy"
  ]
    describe "bag:#{i}", ->
      it "should verify that bag:#{i} doesn't do anything (should return Not supported.)", ->
        Bag[i] {}, send: (data) ->
          data.should.equal "Not supported."
