'use strict'
require "./spec_helper.spec"
Auth = require "../../../src/controllers/auth_controller"

# environment-specific config
USER_ID = process.env.USER_ID or "55d3b333e2bf182b637341dc" # my user id (rgausnet)
USER_NAME = process.env.USER_NAME or "rgausnet"
USER_PASS = process.env.USER_PASS or "bacon"

describe "auth handshake", ->

  it "auth handshake with good user name and password", (done) ->
    Auth.handshake
      body:
        username: USER_NAME
        password: USER_PASS
    ,
      send: (data) ->
        data.should.not.be.null
        data.should.be.an.object

        data.should.have.property '_id'
        data._id.toString().should.equal USER_ID
        done()

  for phrase in [
    "bad user creds"
    null
    0
    5
    undefined
    "<% console.log(1) %>"
  ]
    it "auth handshake with bad username and password", (done) ->
      Auth.handshake
        body:
          username: phrase
          password: phrase
      ,
        send: (data) ->
          data.should.not.be.null
          data.should.not.have.property '_id'
          data.err.should.equal "Permission denied."

          done()

    it "auth handshake with bad username and good password", (done) ->
      Auth.handshake
        body:
          username: phrase
          password: USER_PASS
      ,
        send: (data) ->
          data.should.not.be.null
          data.should.not.have.property '_id'
          data.err.should.equal "Permission denied."

          done()

    it "auth handshake with bad password and good username", (done) ->
      Auth.handshake
        body:
          username: USER_NAME
          password: phrase
      ,
        send: (data) ->
          data.should.not.be.null
          data.should.not.have.property '_id'
          data.err.should.equal "Permission denied."

          done()
