angular.module('bag.controllers.tab_picks', [])
  
.controller 'PicksCtrl', (
  $scope,
  persistant,
  $state,
  $ionicPopup
  socket
) ->
  # With the new view caching in Ionic, Controllers are only called
  # when they are recreated or on app start, instead of every page change.
  # To listen for when this page is active (for example, to refresh data),
  # listen for the $ionicView.enter event:
  #
  #$scope.$on('$ionicView.enter', function(e) {
  #});
  #
 

  load_picks = ->
    socket.emit "pick:index"
    socket.on "pick:index:callback", (payload) ->
      if payload.data
        $scope.picks = _.sortBy payload.data.picks, (i) -> i.score or 0
      $scope.$broadcast 'scroll.refreshComplete'
  load_picks()

  $scope.do_refresh = -> load_picks()

  # go to "my recipes" view
  $scope.to_user_recipes = -> $state.go "tab.recipes"

  # more info for an item
  $scope.more_info = (item) ->
    $state.go "tab.recipeinfo", id: item._id

  $scope.delete_item = (pick) ->
    $scope.picks = _.without $scope.picks, pick

    # issue a request back to the server to delete the pick
    socket.emit "pick:delete", pick: pick._id

  ###
  # Initialization
  ###
  $scope.host = window.host
