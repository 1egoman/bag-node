Pick = require "../models/pick_model"
List = require "../models/list_model"
async = require 'async'
_ = require "underscore"

Recipe = require "../models/list_model"
algo = require "../algo"

# get a foodstuff of all lists
# GET /foodstuff
exports.index = (req, res) ->
  query = Pick.findOne user: req.user._id
  query.exec (err, data) ->
    if err
      res.send
        status: "bag.error.picks.index"
        error: err
    else

      # simplify all picks from the object representation to the item array
      async.map Object.keys(data.picks), (i, cb) ->
        List.findOne _id: i, (err, v) ->
          if err
            cb err
          else if not v
            cb null
          else
            v = v.toObject()
            v.score = data.picks[i]
            cb null, v
      , (err, all) ->

        # get rid of dupes and send it off
        data = data.toObject()
        data.picks = _.compact all
        res.send
          status: "bag.success.picks.index"
          data: data

# the route to regenerate picks
exports.genpicks = (req, res) ->
  algo.query
    user: req.user
  , Recipe, Pick, (err) ->
    if err
      res.send
        status: "bag.error.picks.genpicks"
        error: err
    else
      res.send
        status: "bag.success.picks.genpicks"

# the method to regernerate picks
exports.gen_picks_for = (user, cb) ->
  exports.genpicks
    user: user
  , send: cb

