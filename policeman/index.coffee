require("../src/db") process.env.MONGOLAB_URI or process.env.db or "mongodb://bag:bag@ds047602.mongolab.com:47602/bag-dev"


Store = require "../src/models/store_model"
Foodstuff = require "../src/models/foodstuff_model"
inq = require "inquirer"
async = require "async"
chalk = require "chalk"
_ = require "underscore"

Store.find verified: false
.exec (err, stores) ->
  return console.log err if err


  # loop through the stores, and ask if they are ok or not.
  async.mapSeries stores, (s, cb) ->


    Foodstuff.findOne _id: s.item.toString()
    .exec (err, f) ->
      return console.log err if err

      # look at each of the stores for that item, and see if it matches what the
      # user inputted (we are looking for duplicates)
      async.mapSeries Object.keys(f.stores), (store, cb) ->
        Store.findOne
          verified: true
          _id: store
        , (err, sval) ->
          return cb err if err

          if sval
            # see if the store is a possible match
            score = _.intersection sval.name.split(' '), s.name.split(' ')
            if score
              cb null, sval
            else
              cb null
          else
            cb null

      , (err, matches) ->
        return console.log err if err
        matches = _.compact matches
        
        # get the users opinion
        inq.prompt [
          type: "rawlist"
          message: """
          Store:
            #{chalk.green "Store Name: #{s.name}"}
            #{chalk.cyan  "Item Name: #{f.name}"}
            #{chalk.green "Item Brand: #{s.item_brand}"}
            #{chalk.green "Item Price: #{s.item_price}"}
          """
          name: "resp"
          choices: [
            "Make this a new store"
            "A duplicate, but not listed"
            "Totally junk"
            new inq.Separator()
          ].concat matches.map (m) ->
            "Really a duplicate of #{chalk.red m.name}"
        ], (answers) ->
        
          switch

            # the store is really new.... lets verify it!
            when answers.resp.indexOf('new') isnt -1
              inq.prompt [
                type: "input"
                default: s.name
                message: "Store Name"
                name: "store_name"
              ,
                type: "input"
                message: "Store Desc"
                name: "store_desc"
              ]
              , (out) ->
                store = s

                # save the store
                store.verified = true
                store.name = out.store_name
                store.desc = out.store_desc
                store.save (err) ->
                  return cb err if err
                  console.log "Saved #{chalk.red out.store_name}"
                  cb null, answers

                  # save the foodstuff
                  f.stores[store._id] = price: s.item_price
                  f.markModified "stores.#{store._id}.price" # this is magic

                  f.save (err, user) ->
                    return cb err if err
                    console.log "Saved #{chalk.red f.name}"



            when answers.resp.indexOf('duplicate') isnt -1
              inq.prompt [
                type: "input"
                message: "Enter the store id of the duplicate store"
                name: "store_id"
              ]
              , (out) ->
                store.verified = true
                store.name = out.store_name
                store.desc = out.store_desc
                store.save (err, user) ->
                  return cb err if err
                  console.log "Saved #{chalk.red out.store_name}"
                  cb null, answers

        

    , (err, all) ->
     console.log "Error", err if err

      process.exit 0
