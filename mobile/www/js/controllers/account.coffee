angular.module 'starter.controllers.account', []

.controller 'AccountCtrl', (
  $scope
  user
  $state
) ->

  user.then (user) ->
    $scope.username = user.name


  socket.on 'user:show:callback', (evt) ->
    user = evt.data
    $scope.user_plan = do (plan=user.plan) ->
      switch plan
        when 0 then "Bag Free"
        when 1 then "Bag Pro"
        when 2 then "Bag Executive"
        else "Unknown"

  # store user info
  $scope.refresh_user = ->
    socket.emit 'user:show', user: user_id
  $scope.refresh_user()

  # logout a user
  $scope.logout = ->
    delete localStorage.user
    location.reload()

  # move to stores picker page
  $scope.to_stores_chooser = ->
    $state.go "tab.stores"
