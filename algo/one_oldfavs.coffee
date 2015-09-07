

# convert a milisecond number to days, and floor round to the nearest day.
MILLIS_IN_DAY = 24 * 60 * 60 * 1000
millis_to_days = (millis) -> Math.floor millis / MILLIS_IN_DAY

# number one:
# 1. User accessed a recipe frequently a while ago, but hasn't accessed in a
#    duration. (Oh, and a :)ed recipe in this category will get pushed up further.)
#
# This is a user-bound operation (more :)ed recipes of a user, longer it will
# take)
exports.exec = (user, cb) ->
  # This threshhold is used to determine how many days are we from getting too
  # "old"
  OLD_THRESHOLD = 14 *     24 * 60 * 60 * 1000 # two weeks

  # this is the amount in "score" favs will help an item.
  LIKE_BONUS = 20

  click_index = {}

  do (err=null, user=user) ->
    if err
      # error
    else
      console.log "1. Scanning through #{user.name} - find old favs"

      for c in user.clicks
        time = new Date(c.date).getTime()

        # calculate the current "time score" of an item
        time_score = millis_to_days (Date.now() - OLD_THRESHOLD) - time

        console.log "  time score for #{c.store} is #{time_score}"
        # below, we'll accumulate the time score. What will end up resulting is
        # all times above old_threshold will be negitive, which will pulll down
        # the score, while all time below the threshhold will be positive and
        # raise the score for this specific item.

        if click_index[c.store]
          click_index[c.store] += time_score # add time time score to click count
        else
          click_index[c.store] = time_score # set the click count initially to the time score


      # if an item was liked, give it a little bonus. This will raise it up the
      # list some (the thinking being that a like means the user wants to make the
      # recipe...)
      for l in user.favs
        if click_index[l]
          click_index[l] += LIKE_BONUS

    cb null, click_index

