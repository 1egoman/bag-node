Pick = require "../models/pick_model"
List = require "../models/list_model"
async = require 'async'
_ = require "underscore"

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
            v.score = data.picks[i]
            cb null, v
      , (err, all) ->

        # get rid of dupes and send it off
        data = data.toObject()
        data.picks = _.compact all
        res.send
          status: "bag.success.picks.index"
          data: data

