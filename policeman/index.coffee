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
      return cb err if err

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
        return cb err if err
        matches = _.compact matches
        
        # get the users opinion
        inq.prompt [
          type: "rawlist"
          message: """
          Store:
            #{chalk.red "Store Name: #{s.name}"}
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
            "|Really a duplicate of: #{chalk.red m.name}"
        ], (answers) ->
          store = s
        
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
                default: s.desc
              ,
                type: "input"
                message: "Store Logo"
                name: "store_logo"
                default: s.image
              ,
                type: "input"
                message: "Store Tags"
                name: "store_tags"
                default: s.tags.join(' ')
              ]
              , (out) ->

                # save the store
                store.verified = true
                store.name = out.store_name
                store.desc = out.store_desc
                store.image = out.store_logo
                store.image = out.store_tags.split ' '
                store.save (err) ->
                  return cb err if err
                  console.log "Saved #{chalk.red out.store_name}"

                  # save the foodstuff
                  f.stores[store._id] = price: s.item_price
                  f.markModified "stores.#{store._id}.price" # this is magic

                  f.save (err, user) ->
                    return cb err if err
                    console.log "Saved #{chalk.red f.name}"
                    cb null, answers








            # the store is a dupe...
            # we'll take all the item info from this store and use it to create
            # a new foodstuff attached to the specified store. Then, we'll
            # delete it.
            when answers.resp.indexOf('duplicate') isnt -1

              do_store = (store_name) ->

                # find the store
                Store.findOne name: store_name, (err, store) ->
                  return cb err if err
                  if store

                    # save the foodstuff
                    f.stores[store._id] = price: s.item_price
                    f.markModified "stores.#{store._id}.price" # this is magic

                    f.save (err, user) ->
                      return cb err if err
                      console.log "Saved #{chalk.red f.name}"

                  else
                    console.log "bad store. skipping for now..."




              if answers.resp[0] is '|'
                store = answers.resp.split(': ')[1]
                do_store chalk.stripColor store.trim()
              else
                inq.prompt [
                  type: "input"
                  message: "Enter the store name of the duplicate store"
                  name: "store_id"
                ]
                , (out) ->
                  do_store out.store_id





            # just delete the foodstuff, as it's just garbage
            when answers.resp.indexOf('junk') isnt -1
              Store.remove _id: s._id, (err) ->
                return cb err if err
                console.log "Deleted junk: #{chalk.red s.name}"
        











  , (err, all) ->
    console.log "Error", err if err
    console.log chalk.bold chalk.green "drumroll.... and, we are done!"

    process.exit 0
