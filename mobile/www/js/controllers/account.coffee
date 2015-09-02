angular.module 'starter.controllers.account', []

.controller 'AccountCtrl', (
  $scope
  user
  $state
  $cordovaDialogs
) ->

  user.then (user) ->
    $scope.username = user.name


  socket.on 'user:show:callback', (evt) ->
    user = evt.data

    # get the current plan
    $scope.user_plan or= ""
    old_plan = $scope.user_plan.slice 0
    $scope.user_plan = do (plan=user.plan) ->
      switch plan
        when 0 then "Bag Free"
        when 1 then "Bag Pro"
        when 2 then "Bag Executive"
        else "Unknown"

    # if the current plan is different from the old one, let the user know.
    if old_plan.length and old_plan isnt $scope.user_plan
      $cordovaDialogs.alert "FYI, because of your new plan, some features may not be available until you restart the application.", "Reload App", 'Ok'

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
