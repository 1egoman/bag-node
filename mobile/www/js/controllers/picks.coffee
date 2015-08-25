angular.module('starter.controllers.tab_picks', [])
  
.controller 'PicksCtrl', (
  $scope,
  $ionicModal,
  persistant,
  $state,
  $ionicPopup
) ->
  # With the new view caching in Ionic, Controllers are only called
  # when they are recreated or on app start, instead of every page change.
  # To listen for when this page is active (for example, to refresh data),
  # listen for the $ionicView.enter event:
  #
  #$scope.$on('$ionicView.enter', function(e) {
  #});
  #
 
  picks = [
    {
        "_id": "54c50a4a901b060c006372d4",
        "name": "pumpkin seeds",
        "desc": "raw seeds, lb.",
        "price": 5.00,
        "item_type": {
            "wegmans": "bulk"
        },
        "contents": [],
        "contentsLists": [],
        "__v": 0
    }
  ]

  # add picks to controller
  do (picks) ->
    $scope.picks = _.sortBy picks, (p) -> p.name

  # go to "my recipes" view
  $scope.to_user_recipes = -> $state.go "tab.recipes"

  # more info for an item
  $scope.more_info = (item) ->
    console.log item
    $state.go "tab.recipeinfo", id: item._id
