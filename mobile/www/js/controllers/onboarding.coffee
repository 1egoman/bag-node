angular.module 'starter.controllers.onboarding', []

.controller 'onboardCtrl', (
  $scope
  user

  $state
  $stateParams
) ->

  $scope.to_step = (step) ->
    $state.go "tab.onboard", step: step

  # FIXME: I'm Untested!!!!!!!!!
  $scope.create_account = (realname, email, user, pass) ->
    user =
      realname: realname
      name: user
      email: email
      password: pass
    socket.emit "user:create", user: user

  # starting step in onboarding
  $scope.step = $stateParams.step
  $scope.title = {
    welcome:  "Welcome to Bag!"
    userdetails: "Login Details"
    createaccount: "Create my Account!"
  }[$scope.step]
