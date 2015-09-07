_ = require "underscore"

# this ratio controls how much the total count is biased toward this result.
VIEW_RATIO = 50

# this value controls the varience within the group. (as this gets smaller, the
# closer to VIEW_RATIO this becomes.)
VIEW_EXP = 0.01

# ok, now for the real code...
exports.exec = (user, cb) ->
  console.log "3. Scanning through #{user.name} - views"
  results = user.clicks.map (v) ->
    time = new Date(v.date).getTime()

    # reverse the number
    # we want the small differences (seconds even) to count al large differences,
    # because the scale we are talking about here is more in line with months than
    # years.
    # time = parseInt time.toString().split('').reverse().join('')

    # the core of the algorithm
    # calculate the score, but then mutiply by a power of ten to make the
    # numbers more "different" (we end up throwing away all the starting stuff and
    # looking at the ending stuff)
    score = Math.pow time, -VIEW_EXP
    score = (score*100000)
    score -= Math.floor score
    score *= VIEW_RATIO

    console.log time, score
    console.log "  #{v.store} -> #{score}"

    out = {}
    out[v.store] = score
    out

  .reduce (a, b) ->
    _.extend a, b

  cb null, results
