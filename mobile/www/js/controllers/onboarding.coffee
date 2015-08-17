angular.module 'starter.controllers.onboarding', []

.controller 'onboardCtrl', (
  $scope
  user
  socket
  persistant

  $state
  $stateParams
) ->

  socket.on "user:create:callback", console.log.bind(console)



  $scope.to_step = (step) ->
    # save the user object
    persistant.new_user = $scope.user

    # now, go to the route
    $state.go "tab.onboard", step: step



  # FIXME: I'm Untested!!!!!!!!!
  $scope.create_account = (user) ->
    # user =
    #   realname: realname
    #   name: user
    #   email: email
    #   password: pass
    console.log user
    socket.emit "user:create", user: user



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
