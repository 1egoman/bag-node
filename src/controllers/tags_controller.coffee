exports.tags = [
  "gluten-free"
  "vegetarian"
  "vegan"
  "milk-free"
]


# get the whole list of tags
exports.index = (req, res) ->
  res.send data: exports.tags

# get all tags that contain the phrase specified
exports.show = (req, res) ->
  res.send
    data: exports.tags.filter (t) ->
      t.indexOf(req.params.tag) isnt -1
