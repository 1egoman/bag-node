angular.module 'starter.controllers.account', []

.controller 'AccountCtrl', (
  $scope
  user
  $state
) ->

  # store user info
  $scope.refresh_user = ->
    user.clear()
    user.then (user) ->
      $scope.username = user.name
      $scope.user_plan = do (plan=user.plan) ->
        switch plan
          when 0 then "Bag Free"
          when 1 then "Bag Pro"
          when 2 then "Bag Executive"
          else "Unknown"
  $scope.refresh_user()

  # logout a user
  $scope.logout = ->
    delete localStorage.user
    location.reload()

  # move to stores picker page
  $scope.to_stores_chooser = ->
    $state.go "tab.stores"
