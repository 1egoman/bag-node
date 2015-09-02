User = require "../models/user_model"
auth_ctrl = require "../controllers/auth_controller"
stripe = require("stripe") "sk_test_lRsLtNDZ9EBsX2NrFx07H5mO"
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
    User.findOne _id: req.session.user._id, (err, user) ->
      req.session.user = user if not err
      next()
  else
    res.redirect "/login?redirect=#{req.url}"

# the basic admin management page. THis is the "hub" that everything else comes
# off of.
exports.manage = (req, res) ->
  exec = if req.session.user.plan is 2 then "You have " else "Upgrade to "
  pro = if req.session.user.plan is 1
    "You have "
  else if req.session.user.plan is 2
    "Downgrade to "
  else
    "Upgrade to "
  free = if req.session.user.plan is 0 then "You have " else "Downgrade to "

  res.send format_page """
  <h1>Welcome, #{req.session.user.realname}</h1>

  <div class="payments">
    <a href="/checkout/free">#{free}Bag Free</a>
    <a href="/checkout/pro">#{pro}Bag Pro</a>
    <a href="/checkout/exec">#{exec}Bag Exec</a>
  </div>

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
      type = "pro"


    when "exec", "e", "executive"
      price = 1000
      desc = "Bag Executive ($10.00)"
      type = "exec"

    # downgrade back to a free account.
    else
      if req.session.user.stripe_id

        # delete the stripe customer
        stripe.customers.del req.session.user.stripe_id, (err, confirm) ->
          if err
            res.send "Error deleting stripe user: #{err}"
          else
            res.send "Your plan has been cancelled. You have been downgraded to our free plan."

        # remove all payment info and subscription stuff.
        User.findOne _id: req.session.user._id, (err, user) ->
          if err
            res.send "Couldn't get user: #{err}"
          else
            user.stripe_id = null
            user.plan = 0
            user.plan_expire = null
            user.save (err) ->
              if err
                res.send "Couldn't save to database: #{err}"
              else
                # res.send "Canceled bag plan."
      else
        res.send "It seems you aren't signed up for any plan right now."

      return

  # checkout with the payment info specified.
  res.send """
  <!-- stripe checkout -->
  <form action="/checkout_complete" method="POST">
    <input type="hidden" name="type" value="#{type}" />
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
  if req.body.stripeToken and req.body.stripeEmail

    # sign user up for the subscription
    if req.body.type in ["pro", "exec"]

      # delete any old customers with a specified token
      # we don't care about any errors, because we are injecting a fake token
      # after all. This really should be made better, but for now it is probably
      # fine.
      stripe.customers.del req.session.user.stripe_id or "something_else", (err, confirm) ->
        stripe.customers.create
          source: req.body.stripeToken
          plan: "bag_#{req.body.type}"
          email: req.body.stripeEmail
        , (err, customer) ->
          if err
            res.send "Error creating customer: #{err}"
          else

            # save customer data to database
            User.findOne _id: req.session.user._id, (err, user) ->
              if err
                res.send "Couldn't access database: #{err}"
              else
                user.stripe_id = customer.id
                user.save (err) ->
                  if err
                    res.send "Couldn't save user: #{err}"
                  else
                    # wait for the charge to go through...
                    pending_charges[customer.id] =
                      req: req
                      res: res

    else
      res.send "Invalid type to get - needs to be 'pro' or 'exec'."

  else
    res.send "No stripe info was sent in the transaction."


# after a card has been used, stripe will respond with a webhook. 
exports.stripe_webhook = (req, res) ->
  customer = req.body.data?.object?.customer
  return res.send "Bad customer." if not customer

  switch req.body.type

    # a successful card charge. We'll use this to increase the end date of a
    # user's subscription.
    when "invoice.payment_succeeded"
      if customer of pending_charges
        
        # update the users length of payment by a month.
        User.findOne stripe_id: customer, (err, user) ->
          if err
            res.send "Couldn't access user: #{err}"

            # uhoh - the user should contact us for help.
            pending_charges[customer].res.send """
            Hey! Something went wrong with your payment! (NOACCUSER)
            Contact support@getbag.io with this token: #{customer}
            """
          else
            # set up the plan
            user.plan = 0
            user.plan = 1 if req.body.data?.object?.subtotal is 500
            user.plan = 2 if req.body.data?.object?.subtotal is 1000

            # add one more month, in milliseconds
            user.plan_expire or= new Date().getTime() # by default, this is the current time.
            user.plan_expire += do ->
              date = new Date
              month_days = new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate()
              month_days * 60 * 60 * 24 * 1000

            # save the new user token stuff
            user.save (err) ->
              if err
                res.send "Couldn't save user: #{err}"

                # uhoh - the user should contact us for help.
                pending_charges[customer].res.send """
                Hey! Something went wrong with your payment! (NOSAVEUSER)
                Contact support@getbag.io with this token: #{customer}
                """
              else
                res.send "Cool, thanks stripe!"

                # respond to the pending request
                if customer of pending_charges
                  pending_charges[customer].res.send """
                  You have successfully signed up for Bag!
                  
                  You should receive a receipt by email soon. In the meantime, enjoy!
                  """
      else
        # uhh, what??? That card was never used????
        res.send "Uh, that card was never used. What are you talking about stripe???"


    when "charge.failed"
      if consumer of pending_charges
        pending_charges[consumer].res.send """
        Your card didn't charge.
        
        If you think this is in error, contact us at support@getbag.io and provide this token: #{consumer}
        """
        res.send "Cool, thanks stripe!"
      else
        1 # uhh, what??? That card was never used????
        res.send "Uh, that card was never used. What are you talking about stripe???"

    else
      res.send "Thanks anyway, but we didn't need this event."
