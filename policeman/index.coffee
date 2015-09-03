require("../src/db") process.env.MONGOLAB_URI or process.env.db or "mongodb://bag:bag@ds047602.mongolab.com:47602/bag-dev"


Store = require "../src/models/store_model"
Foodstuff = require "../src/models/foodstuff_model"
Bag = require "../src/models/bag_model"
inq = require "inquirer"
async = require "async"
chalk = require "chalk"
_ = require "underscore"

Store.find verified: false
.exec (err, stores) ->
  return console.log err if err


  Foodstuff.find verified: false
  .exec (err, foodstuffs) ->
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
                        cb null

                    else
                      console.log "bad store. skipping for now..."
                      cb null




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
                  cb null
          











    , (err, all) ->
      console.log "Error", err if err
      console.log chalk.bold chalk.green "drumroll.... and, we are done with the stores!"



      # loop through the foodstuffs, and ask if they are ok or not.
      async.mapSeries foodstuffs, (f, cb) ->

          # try and find any duplicates
          query = for word in f.name.split ' '
            name: new RegExp word, 'i'
            _id: $ne: f._id

          Foodstuff.find $or: query
          .exec (err, related) ->
            return cb err if err

            console.log related


            # get the users opinion
            inq.prompt [
              type: "rawlist"
              message: """
              Foodstuff:
                #{chalk.red  "Item Name: #{f.name}"}
                #{chalk.green "Item Desc: #{f.desc}"}
                #{chalk.green "Item Tags: #{f.tags}"}
                #{chalk.green "Item Price: #{f.price}"}
                #
              """
              name: "resp"
              choices: [
                "Make this a new foodstuff"
                "Unlisted duplicate"
                "Totally junk"
              ].concat related.map (r) ->
                "|Really a duplicate of: #{chalk.red r.name}"
            ], (answers) ->
              switch






                # the foodstuff is really new.... lets verify it!
                when answers.resp.indexOf('new') isnt -1
                  inq.prompt [
                    type: "input"
                    default: f.name
                    message: "Foodstuff Name"
                    name: "foodstuff_name"
                  ,
                    type: "input"
                    message: "Foodstuff Desc"
                    name: "foodstuff_desc"
                    default: f.desc
                  ,
                    type: "input"
                    message: "Foodstuff Price"
                    name: "foodstuff_price"
                    default: f.price
                  ,
                    type: "input"
                    message: "^^ At what store"
                    name: "store"
                  ,
                    type: "input"
                    message: "Foodstuff Tags"
                    name: "foodstuff_tags"
                    default: f.tags.join ' '
                  ]
                  , (out) ->

                    # get store info
                    Store.findOne name: out.store, (err, store) ->
                      return cb err if err

                      f.stores[store._id] = price: f.price

                      # save the foodstuff
                      f.verified = true
                      f.name = out.foodstuff_name
                      f.desc = out.foodstuff_desc
                      f.image = out.foodstuff_logo
                      f.image = out.foodstuff_tags.split ' '
                      f.price = undefined
                      f.save (err) ->
                        return cb err if err
                        console.log "Saved #{chalk.red out.foodstuff_name}"
                        cb null, answers



                # the store is a dupe...
                # we'll take all the item info from this store and use it to create
                # a new foodstuff attached to the specified store. Then, we'll
                # delete it.
                when answers.resp.indexOf('duplicate') isnt -1

                  do_fds = (fds_name) ->
                    #TODO replace within a user's bag
                    1




                  if answers.resp[0] is '|'
                    store = answers.resp.split(': ')[1]
                    do_fds chalk.stripColor store.trim()
                  else
                    inq.prompt [
                      type: "input"
                      message: "Enter the store name of the duplicate store"
                      name: "store_id"
                    ]
                    , (out) ->
                      do_fds out.store_id




                # just delete the foodstuff, as it's just garbage
                when answers.resp.indexOf('junk') isnt -1
                  console.log f

                  # delete from the bag
                  Bag.findOne user: f.user, (err, bag) ->

                    return cb err if err

                    # remove in the user's bag
                    bag.contents = bag.contents.filter (c) -> c._id.toString() isnt f._id.toString()
                    bag.markModified "contents"

                    bag.save (err) ->
                      return cb err if err


                      # delete the physical item, too
                      Foodstuff.remove _id: f._id, (err) ->
                        return cb err if err
                        console.log "Deleted junk: #{chalk.red f.name}"
                        cb null

        , (err, data) ->
          return console.log err if err
          console.log chalk.bold chalk.cyan "drumroll.... and, we are done, like, completely!"
          

          process.exit 0
