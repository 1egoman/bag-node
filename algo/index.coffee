#!/usr/bin/env coffee
async = require "async"

# connect to database
require("./db") "mongodb://heroku_lvm2p4zk:27me0oje7us7b97s3pg9s7ooak@ds035703.mongolab.com:35703/heroku_lvm2p4zk", ->
  Recipe = require "./models/list_model"
  User = require "./models/user_model"
  Pick = require "./models/pick_model"

  query
    user_id: "55d3b333e2bf182b637341dc"
  , Recipe, User, Pick


query = (opts, Recipe, User, Pick) ->

  Recipe.find {}, (err, recipes) ->
    if err
      # error
    else

      # get our user
      User.findOne _id: opts.user_id, (err, user) ->

        # make sure we've got user.clicks
        user.clicks or= []

        all = [
          require("./one_oldfavs").exec.bind null, user
          require("./two_similaring").exec.bind null, user, Recipe, recipes
          require("./three_views").exec.bind null, user
        ]

        # using all of these items, lets compile a total score.
        totals = {}
        async.map all, (i, cb) ->
          i cb
        , (err, all) ->
          for i in all
            for k,v of i
              if k of totals
                totals[k] += v
              else
                totals[k] = v


          console.log totals

          # add choices to picks on server
          Pick.findOne user: user._id, (err, pick) ->
            if err
              return console.log err
            else
              all = _.compact _.map totals, (v, k) ->
                if k not in pick.blacklist
                  key: k
                  value: v
                else
                  null

              picks.pick = _.object _.pluck(all, 'key'), _.pluck(all, 'value')


              pick.save (err) ->
                if err
                  return console.log err
                else
                  console.log "Wrote picks!"
                  console.log all
