User = require "../models/user_model"

# do an authentication handshake - pass in user creds
# and get back the usr object
exports.handshake = (req, res) ->
  User.findOne
    name: req.body.username
    token: req.body.password
  .exec (err, data) ->
    if err
      res.send err: err
    else if data
      res.send data
    else
      res.send msg: "Permission denied."
