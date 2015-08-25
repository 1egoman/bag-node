angular.module 'starter.controllers.onboarding', []

.controller 'onboardCtrl', (
  $scope
  user
  socket
  persistant

  $state
  $stateParams
) ->

  # once user has been created, then this callback will fire and the user will
  # be moved to the tutorial or given an error.
  socket.on "user:create:callback", (payload) ->
    if payload.status is "bag.success.user.create"

      do (data=payload.data) ->

        # store in session
        localStorage.user = JSON.stringify
          id: data._id
          token: data.token

        # HACKY ALERT!!!
        # to get the page to re "pull in" all the stuff, reload
        setTimeout ->
          location.replace('#/tab/bag')
          location.reload()
        , 2000


      # lastly, redirect to tutorial
      # are we still doing this???? TODO
      # $state.go "tab.howtouse"
    else
      $scope.error_logs = "Error creating account: \n#{JSON.stringify payload, null, 2}"


  # is the specified username unique?
  socket.on "user:unique:callback", (payload) ->
    $scope.username_clean = payload.status.indexOf("clean") > -1


  # move to a new onboarding step
  $scope.to_step = (step) ->
    # save the user object
    persistant.new_user = $scope.user

    # now, go to the route
    $state.go "tab.onboard", step: step


  # create a user account
  $scope.create_account = (user) ->
    $scope.creating_user = user
    socket.emit "user:create", user: user


  # our hack to reload the app
  # HACKY ALERT!!!
  $scope.to_app = ->
    setTimeout ->
      location.replace('#/tab/bag')
      location.reload()
    , 2000
    # $state.go "tab.login"


  # is a username unique?
  $scope.check_user_unique = (user) -> socket.emit "user:unique", user: user
  $scope.username_clean = false

  # starting step in onboarding
  $scope.step = $stateParams.step
  $scope.title = {
    welcome:  "Welcome to Bag!"
    userdetails: "Login Details"
    createaccount: "Create my Account!"
  }[$scope.step]
  
  # we save our onboarading info in this object, which is backed up to
  # persistant storage through the persistant service
  $scope.user = persistant.new_user or {}
