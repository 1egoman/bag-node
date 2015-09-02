User = require "../models/user_model"
auth_ctrl = require "../controllers/auth_controller"
pending_charges = {}

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


# set up a new plan, and upgrade your account.
exports.checkout = (req, res) ->
  switch req.params.plan

    when "pro", "p", "professional"
      price = 500
      desc = "Bag Professional ($5.00)"


    when "exec", "e", "executive"
      price = 1000
      desc = "Bag Executive ($10.00)"

    # downgrade back to a free account.
    #TODO
    else
      res.send "Lets cancel thet."
      return

  res.send """
  <!-- stripe checkout -->
  <form action="/checkout_complete" method="POST">
    <script
      src="https://checkout.stripe.com/checkout.js" class="stripe-button"
      data-key="pk_test_k280ghlxr7GrqGF9lxBhy1Uj"
      data-amount="#{price}"
      data-name="Bag"
      data-description="#{desc}"
      data-image="//getbag.io/img/bag.svg"
      data-locale="auto">
    </script>
  </form>
  """

# this callback fires when the user finishes checking out with stripe
exports.checkout_complete = (req, res) ->
  console.log req.body
  User.findOne _id: req.session.user._id, (err, user) ->
    if err
      res.send "Couldn't access database: #{err}"
    else
      user.stripe_id = req.body.stripeToken # this is injected via stripe
      user.save (err) ->
        if err
          res.send "Couldn't save user: #{err}"
        else
          # store into the pending transactions
          pending_charges[user.stripe_id] =
            req: req
            res: res
          # we'll wait for stripe to respond.


# after a card has been used, stripe will respond with a webhook. 
exports.stripe_webhook = (req, res) ->
  card_id = req.body.data?.object?.id
  console.log req.body
  switch req.body.type

    when "charge.succeeded"
      if card_id of pending_charges
        pending_charges[card_id].res.send "Card was charged successfully!"
        res.send "Cool, thanks stripe!"
      else
        1 # uhh, what??? That card was never used????
        res.send "Uh, that card was never used. What are you talking about stripe???"


    when "charge.failed"
      if card_id of pending_charges
        pending_charges[card_id].res.send "Card didn't charge. Any idea why this would happen?"
        res.send "Cool, thanks stripe!"
      else
        1 # uhh, what??? That card was never used????
        res.send "Uh, that card was never used. What are you talking about stripe???"

    else
      res.send "Thanks anyway, but we didn't need this event."
