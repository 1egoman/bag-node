'use strict'
require "./spec_helper.spec"
Foodstuff = require "../../../src/controllers/foodstuff_controller"

# environment-specific config
USER_ID = process.env.USER_ID or "55d3b333e2bf182b637341dc" # my user id (rgausnet)

describe "foodstuff queries", ->

  # clean up first
  before (done) ->
    require("../../../src/models/foodstuff_model")
    .remove name: "test item", done


  # foodstuff:index
  # get the foodstuff for the specified user
  describe "foodstuff:index", ->
    it "foodstuff:index returns info with valid user id", (done) ->
      Foodstuff.index
        user: _id: USER_ID
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

    it "foodstuff:index returns only my items with user: 'me'", (done) ->
      Foodstuff.index
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

          done()

    for u_id in [
      "bad user id"
      null
      0
      5
      undefined
      "<% console.log(1) %>"
    ]
      it "foodstuff:index returns null data with bad user id that is '#{u_id}'", (done) ->
        Foodstuff.index
          user: _id: u_id
          body:
            user: 'me'
        ,
          send: (data) ->
            data.should.not.be.null
            data.status.should.contain "success"
            data.data.should.be.an "array"
            data.data.should.be.empty

            done()


  describe "foodstuff:create", ->

    it "foodstuff:create will create a new public, unverified foodstuff", (done) ->
      Foodstuff.create
        body:
          foodstuff:
            name: "test item"
            desc: "used in tests for foodstuff, please delete me"
            tags: []
            price: 5
        user:
          _id: USER_ID
          plan: 0
      ,
        send: (data) ->
          data.should.not.be.null
          data.status.should.contain "success"
          data.data.should.be.an.object

          data.data.verified.should.be.false
          data.private.should.be.false

          done()

    it "foodstuff:create will not create a new private foodstuff with user plan of free", (done) ->
      Foodstuff.create
        body:
          foodstuff:
            name: "test item"
            desc: "used in tests for foodstuff, please delete me"
            tags: []
            price: 5
            private: true
        user:
          _id: USER_ID
          plan: 0
      ,
        send: (data) ->
          # still works, but just a public one
          data.should.not.be.null
          data.status.should.contain "success"
          data.data.should.be.an.object

          data.data.verified.should.be.false
          data.private.should.be.false

          done()

    it "foodstuff:create will create a private foodstuff with a user plan > 0", (done) ->
      Foodstuff.create
        body:
          foodstuff:
            name: "test item"
            desc: "used in tests for foodstuff, please delete me"
            tags: []
            price: 5
            private: true
        user:
          _id: USER_ID
          plan: 1
      ,
        send: (data) ->
          data.should.not.be.null
          data.status.should.contain "success"
          data.data.should.be.an.object

          data.data.verified.should.be.false
          data.private.should.be.true

          done()

    describe "foodstuff:create will only let 10 private foodstuffs be made for a user plan == 1", ->
      # delete all foodstuffs
      before (done) ->
        require("../../../src/models/foodstuff_model")
        .remove name: "test item", done

      # create 10 foodstuffs to fill up the "queue"
      for i in [1..10]
        it "foodstuff:create (iteration #{i})", (done) ->
          Foodstuff.create
            body:
              foodstuff:
                name: "test item"
                desc: "used in tests for foodstuff, please delete me"
                tags: []
                price: 5
                private: true
            user:
              _id: USER_ID
              plan: 1
          ,
            send: (data) ->
              data.should.not.be.null
              data.status.should.contain "success"
              data.data.should.be.an.object

              data.data.verified.should.be.false
              data.private.should.be.true

              done()

      it "foodstuff:create (iteration 11) - this shouldn't work", (done) ->
        Foodstuff.create
          body:
            foodstuff:
              name: "test item"
              desc: "used in tests for foodstuff, please delete me"
              tags: []
              price: 5
              private: true
          user:
            _id: USER_ID
            plan: 1
        ,
          send: (data) ->
            data.should.not.be.null
            data.status.should.contain "error"
            data.error.should.equal "Reached max private foodstuffs."
            done()

    describe "foodstuff:create will let infinite private foodstuffs be made for user plan > 1", ->
      # delete all foodstuffs
      before (done) ->
        require("../../../src/models/foodstuff_model")
        .remove name: "test item", done

      # create 20 foodstuffs to fill up the "queue"
      for i in [1..20]
        it "foodstuff:create (iteration #{i})", (done) ->
          Foodstuff.create
            body:
              foodstuff:
                name: "test item"
                desc: "used in tests for foodstuff, please delete me"
                tags: []
                price: 5
                private: true
            user:
              _id: USER_ID
              plan: 2
          ,
            send: (data) ->
              data.should.not.be.null
              data.status.should.contain "success"
              data.data.should.be.an.object

              data.data.verified.should.be.false
              data.private.should.be.true

              done()
