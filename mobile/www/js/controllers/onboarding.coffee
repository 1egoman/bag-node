angular.module 'starter.controllers.onboarding', []

.controller 'onboardCtrl', (
  $scope
  user
  socket
  persistant

  $state
  $stateParams
) ->

  socket.on "user:create:callback", (payload) ->
    if payload.status is "bag.success.user.create"
      $state.go "tab.onboard", step: "created_user"
    else
      console.log payload
      $state.go "tab.onboard.failed_create_user" 


  $scope.to_step = (step) ->
    # save the user object
    persistant.new_user = $scope.user

    # now, go to the route
    $state.go "tab.onboard", step: step



  # create a user account
  $scope.create_account = (user) -> socket.emit "user:create", user: user



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
