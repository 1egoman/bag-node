#!/usr/bin/env coffee
async = require "async"

one = require "./one_oldfavs"
two = require "./two_similaring"
three = require "./three_views"

exports.query = (opts, Recipe, Pick, cb) ->

  Recipe.find {}, (err, recipes) ->
    if err
      cb err
    else

      # get our user
      do (user=opts.user) ->

        # make sure we've got user.clicks
        user.clicks or= []

        all = [
          one.exec.bind null, user
          two.exec.bind null, user, Recipe, recipes
          three.exec.bind null, user
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

          # add choices to picks on server
          Pick.findOne user: user._id, (err, pick) ->
            if err
              cb err
            else
              pick.picks = totals

              pick.save (err) ->
                if err
                  cb err
                else
                  cb null
