'use strict'
require "./spec_helper.spec"
Account = require "../../../src/account"
User = require "../../../src/models/user_model"

# environment-specific config
USER_ID = process.env.USER_ID or "55d3b333e2bf182b637341dc" # my user id (rgausnet)
USER_NAME = process.env.USER_NAME or "rgausnet"
USER_PASS = process.env.USER_PASS or "bacon"

describe "payments testing", ->

  describe "page protection", ->
    it "does let in authorized users", (done) ->
      req =
        session: user:
          _id: USER_ID

      Account.protect req, redirect: (url) ->
        # redirect on failure
        url.should.be.empty
        done()
      , ->
        # next callback
        # we're good here
        done()

    it "doesn't let in empty users", (done) ->
      req = session: {}

      Account.protect req, redirect: (url) ->
        # redirect on failure
        url.should.not.be.empty
        url.should.contain "/login?"
        done()
      , ->
        # next callback
        "unauthorized user let in".length.should.equal 0

    it "doesn't let in unauthorized users", (done) ->
      req = session: user: _id: "bogus"

      Account.protect req, redirect: (url) ->
        # redirect on failure
        url.should.not.be.empty
        url.should.contain "/login?"
        done()
      , ->
        # next callback
        "unauthorized user let in".length.should.equal 0



  describe "login a user", ->
    it "does let authorized users login", (done) ->
      req =
        session: {}
        body:
          username: USER_NAME
          password: USER_PASS

      Account.login_post req,
        redirect: (url) ->
          # redirect on success to /manage
          url.should.not.be.empty
          url.should.contain "/manage"
          done()
        send: (data) ->
          data.should.not.contain "Error"
          done()

    it "does not let unauthorized users login", (done) ->
      req =
        session: {}
        body:
          username: "bogus"
          password: "bogus"

      Account.login_post req,
        redirect: (url) ->
          # redirect on success to /manage
          "unauthorized user let in".length.should.equal 0
          url.should.not.contain "/manage"
          done()
        send: (data) ->
          data.should.contain "Error"
          done()

    it "login page renders", ->
      Account.login_get {}, send: (data) ->
        data.should.contain "<html>"

  describe "user can be upgraded from free -> pro", ->
    customer_id = null

    # create a user to "upgrade"
    before (done) ->
      User.remove name: "testy", (err) ->
        if err then return done err
        new User
          realname: "Mr. Test"
          name: "testy"
          password: "secret12"
          plan: 0

        .save done

    it "user is currently a free user", (done) ->
      User.findOne name: "testy", (err, user) ->
        if err then return done err
        user.toObject().plan.should.equal 0
        done()

    it "fetch the buy page", (done) ->
      Account.checkout
        params: plan: "pro"
      , send: (data) ->
        data.should.contain "<html>"
        done()

    #TODO we need to generate a new cc token each time
#    it "perform the actual payment", (done) ->
#      # create a card for testing
#      Stripe.card.createToken
#      Account.checkout_complete
#        session:
#          user:
#            stripe_id: null
#
#        body:
#          stripeToken: "tok_u5dg20Gra"
#          stripeEmail: "my@email.com"
#          type: "pro"
#      ,
#        send: (data) ->
#          console.log data
#        test_get_customer_id: (id) ->
#          customer_id = id
#          console.log 123
#
#          #let code know the card has been "accepted"
#          Account.stripe_webhook
#            body:
#              type: "invoice.payment_succeeded"
#              data:
#                object:
#                  customer: customer_id
#          , send: (data) ->
#            data.should.contain "thanks"
#            console.log 1
#
