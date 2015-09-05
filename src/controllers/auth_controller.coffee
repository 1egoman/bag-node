User = require "../models/user_model"
bcrypt = require "bcrypt"

# do an authentication handshake - pass in user creds
# and get back the usr object
exports.handshake = (req, res) ->

  User.findOne
    name: req.body.username
  .exec (err, data) ->
    if err
      res.send err: err
    else if data

      # hash password and test it
      bcrypt.hash req.body.password, data.salt, (err, hash) ->
        if err
          res.send err: err
        else
          if hash is data.password
            res.send data
          else
            res.send err: "Permission denied."

    # username doesn't exist
    else
      res.send err: "Permission denied."
