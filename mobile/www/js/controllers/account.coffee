angular.module 'starter.controllers.account', []

.controller 'AccountCtrl', (
  $scope
  user
  $state
) ->

  # store user info
  user.then (user) ->
    $scope.username = user.name

  # logout a user
  $scope.logout = ->
    delete localStorage.user
    location.reload()

  # move to stores picker page
  $scope.to_stores_chooser = ->
    $state.go "tab.stores"
