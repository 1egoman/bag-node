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

# basic auth handler
# if a user is in the session, then allow them through, otherwise, redirect to
# the login page.
exports.protect = (req, res, next) ->
  if req.session.user
    next()
  else
    res.redirect "/login?redirect=#{req.url}"

# the basic admin management page. THis is the "hub" that everything else comes
# off of.
exports.manage = (req, res) ->
  res.send format_page """
  <h1>Welcome, #{req.session.user.realname}</h1>
  <a href="/checkout/pro">Get Bag Pro</a>
  <a href="/checkout/exec">Get Bag Exec</a>
  <br/>
  <a href="/logout">Logout</a>
  """

# the login page
exports.login_get = (req, res) ->
  res.send format_page """
  <form method="POST">
    <input type="text" name="username" placeholder="Username" />
    <input type="text" name="password" placeholder="Password" />
    <input type="submit" />
  </form>
  """

# The login handler. This route grabs the login info and checks it.
exports.login_post = (req, res) ->
  if req.body.username and req.body.password
    auth_ctrl.handshake
      body: req.body
      type: 'ws'
    , send: (payload) ->
      if payload.err
        res.send "Error: #{payload.err}"
      else
        req.session.user = payload
        res.redirect req.query?.redirect or "/manage"

  else
    res.send "Error: No username or password provided."

# logout handler
exports.logout = (req, res) ->
  req.session.user = null
  res.redirect "//getbag.io"


exports.checkout = (req, res) ->
  res.send "yay"
