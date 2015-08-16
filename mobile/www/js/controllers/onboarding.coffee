angular.module 'starter.controllers.onboarding', []

.controller 'onboardCtrl', (
  $scope
  user

  $state
  $stateParams
) ->

  $scope.to_step = (step) ->
    $state.go "tab.onboard", step: step

  # starting step in onboarding
  $scope.step = $stateParams.step
  $scope.title = {
    welcome:  "Welcome to Bag!"
    userdetails: "Login Details"
    createaccount: "Create my Account!"
  }[$scope.step]
