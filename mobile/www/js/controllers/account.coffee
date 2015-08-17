angular.module 'starter.controllers.account', []

.controller 'AccountCtrl', (
  $scope
  user
) ->

  # store user info
  user.then (user) ->
    $scope.username = user.name

  # logout a user
  $scope.logout = ->
    delete sessionStorage.user
    location.reload()

