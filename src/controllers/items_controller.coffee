async = require "async"
_ = require "underscore"

list_ctrl = require "./list_controller"
foodstuff_ctrl = require "./foodstuff_controller"

exports.items = [list_ctrl, foodstuff_ctrl]

exports.search = (req, res) ->
  item = req.params.item

  async.map exports.items, (i, cb) ->
    i.search
      params:
        list: item
        foodstuff: item
    ,
      send: (data) ->
        if data.status.indexOf('error') isnt -1
          cb true, data
        else
          cb null, data.data
  , (err, data) ->
    if err
      res.send
        status: "bag.error.item.search"
        error: err
    else
      res.send
        status: "bag.success.item.search"
        data: _.reduce data, (a, b) -> a.concat b

