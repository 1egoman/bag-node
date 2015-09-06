'use strict'
require "./spec_helper.spec"
List = require "../../../src/controllers/list_controller"

# environment-specific config
USER_ID = "55d3b333e2bf182b637341dc" # my user id (rgausnet)

describe "list queries", ->
  test_list = null


  # bag:index
  # get the bag for the specified user
  describe "bag:index", ->
    it "bag:index returns info with valid user id", (done) ->
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


  # bag:update
  # update the bag for a specific user
  describe "list:update", ->
    it "list:update will update a valid list", (done) ->

      # add a new item to the bag
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
      it "bag:update returns null data with bad user id that is '#{cnts}'", (done) ->
        List.update
          params: list: cnts
          body: list: cnts
        ,
          send: (data) ->
            data.should.not.be.null
            data.status.should.contain "error"
            done()

  # # bag:update_store
  # # within a bag, replace every store instance with another.
  # describe "bag:update_store", ->
  #
  #   # TODO we should test this further to make sure the substitution happened
  #   it "should be able to successfully replace our test item", (done) ->
  #     Bag.update_store
  #       user:
  #         _id: USER_ID
  #         plan: 0
  #       body:
  #         item: "test item"
  #         store: "test store two"
  #     , send: (data) ->
  #       data.should.not.be.null
  #       data.status.should.contain "success"
  #       data.data.should.be.an.object
  #
  #       # data information
  #       data.data.user.should.equal USER_ID
  #       data.data.contents.should.be.an.object
  #       data.data.contentsLists.should.be.an.object
  #
  #       # normal contents
  #       if data.data.contents.length
  #         data.data.contents[0].should.be.an.object
  #         data.data.contents[0].name.should.be.a.string
  #         data.data.contents[0]._id.should.be.a.string
  #
  #       # list contents
  #       if data.data.contentsLists.length
  #         data.data.contentsLists[0].should.be.an.object
  #         data.data.contentsLists[0].name.should.be.a.string
  #         data.data.contentsLists[0]._id.should.be.a.string
  #
  #       done()
  #
  #   it "bad user id", (done) ->
  #     Bag.update_store
  #       user:
  #         _id: "bla"
  #         plan: 0
  #       body:
  #         item: "test item"
  #         store: "test store two"
  #     , send: (data) ->
  #       data.should.not.be.null
  #       data.status.should.contain "error"
  #       (data.data is null).should.be.true
  #       done()
  #
  #   it "bad item id", (done) ->
  #     Bag.update_store
  #       user:
  #         _id: USER_ID
  #         plan: 0
  #       body:
  #         item: "I don't exist"
  #         store: "test store two"
  #     , send: (data) ->
  #       data.should.not.be.null
  #       data.status.should.contain "success" # need to figure this out FIXME
  #       done()
  #
  #   it "bad store", (done) ->
  #     Bag.update_store
  #       user:
  #         _id: USER_ID
  #         plan: 0
  #       body:
  #         item: "test item"
  #         store: null # something falsey
  #     , send: (data) ->
  #       data.should.not.be.null
  #       data.status.should.contain "error"
  #       (data.data is null).should.be.true
  #       done()



  # unsupported routes
  for i in [
    "new"
    "edit"
  ]
    describe "bag:#{i}", ->
      it "should verify that bag:#{i} doesn't do anything (should return Not supported.)", ->
        List[i] {}, send: (data) ->
          data.should.equal "Not supported."
