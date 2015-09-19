'use strict'
require "./spec_helper.spec"
Account = require "../../../src/account"

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


