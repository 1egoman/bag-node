exports.tags = [
  "gluten-free"
  "vegetarian"
  "vegan"
  "milk-free"
]


# get the whole list of tags
exports.index = (req, res) ->
  res.send
    status: "bag.success.tag.index"
    data: exports.tags

# get all tags that contain the phrase specified
exports.show = (req, res) ->
  matches = exports.tags.filter (t) ->
    t.indexOf(req.params.tag) isnt -1

  if matches.length
    res.send
      status: "bag.success.tag.show"
      data: matches
  else
    res.send
      status: "bag.error.tag.show"
      data: []
