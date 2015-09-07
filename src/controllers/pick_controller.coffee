Pick = require "../models/pick_model"
Recipe = require "../models/list_model"
algo = require "../algo"

# get a foodstuff of all lists
# GET /foodstuff
exports.index = (req, res) ->
  query = Pick.findOne user: req.user._id

  # limit quantity and a start index
  query = query.skip parseInt req.body.start if req.body?.start
  query = query.limit parseInt req.body.limit if req.body?.limit
  
  query.exec (err, data) ->
    if err
      res.send
        status: "bag.error.picks.index"
        error: err
    else
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

