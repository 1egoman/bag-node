User = require "../models/user_model"
auth_ctrl = require "../controllers/auth_controller"

format_page = (data) ->
  """
  <html>
    <head>
      <title>Manage Bag Account</title>
    </head>
    <body>#{data}</body>
  </html>
  """

exports.manage = (req, res) ->
  res.send format_page """
  <a href="/checkout/pro">Get Bag Pro</a>
  <a href="/checkout/exec">Get Bag Exec</a>
  """

exports.login_get = (req, res) ->
  res.send format_page """
  <form method="POST">
    <input type="text" name="username" placeholder="Username" />
    <input type="text" name="password" placeholder="Password" />
    <input type="submit" />
  </form>
  """

exports.login_post = (req, res) ->
  if req.body.username and req.body.password
    auth_ctrl.handshake
      body: req.body
      type: 'ws'
    , send: (payload) ->
      if payload.err
        res.send "Error: #{payload.err}"
      else
        res.send payload

  else
    res.send "Error: No username or password provided."


exports.checkout = (req, res) ->
  res.send "yay"
