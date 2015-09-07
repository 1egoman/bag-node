_ = require "underscore"


# number 2
# A recipe has similar ingredients to a currently :)ed recipe.
# we define recipes with similar ingredients as 2 recipes that share the
# percentage of ingredients defined below or greater. 
#
# TODO find a way to
# distinguish between recipes that are the same (like 2 recipies for foo) and 2
# recipes for foo and a similar subtype of foo - like "cake" and "iced cake".
# THe latter of those two should be used as a filter to restrict scoring to just
# members of that list.
#
# Also, find a way to cache all the intersections below locally so we can just
# zip through all the comparisons. Is ram an issue -> should we use a file or
# database locally?
#
# This is a user-smiley-bound operation, again.

ITEM_PERC = 0.3 # percentage of items that would have to be tha same to consider 2 items to have similar items
ITEM_MULTIP = 5 # multiplier of the final percent (final percents are ranged from 0 to 1)

exports.exec = (user, Recipe, recipes, cb) ->
  click_index = {}

  do (err=null, user=user) ->
    if err
      # error
    else
      console.log "2. Scanning through #{user.name} - similar ingredients"


    # do something like:
    Recipe.find _id: $in: user.favs, (err, user_favs) ->

      if err
        # error
      else
        for r in user_favs

          # a currently liked recipe, but does this recipe have similar
          # ingredients to another?
          for f in recipes
            if f._id.toString() isnt r._id.toString() # don't compare 2 of the same item
              total = _.intersection f.contents.map((c) -> c._id), r.contents.map((c) -> c._id)
              total_perc = total.length / r.contents.length

              console.log "  `#{r.name}` and `#{f.name}` -> #{total_perc}"

              # if the similarity proportion is greater than the threshhold, then add to bag!
              if total_perc >= ITEM_PERC
                console.log "    +1"

                if click_index[r._id]
                  click_index[r._id] += total_perc * ITEM_MULTIP # add time time score to click count
                else
                  click_index[r._id] = total_perc * ITEM_MULTIP # set the click count initially to the time score
        cb null, click_index

