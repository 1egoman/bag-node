#!/usr/bin/env coffee
async = require "async"

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
              cb err
            else
              pick.picks = totals

              pick.save (err) ->
                if err
                  cb err
                else
                  console.log "Wrote picks!"
                  cb null
