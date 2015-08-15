angular.module('starter.controllers.item_info', [])
  
.controller 'ItemInfoCtrl', (
  $scope,
  socket,
  $stateParams,
  $state,
  AllItems,
  $ionicHistory,
  $ionicPopup,
  user,
  $ionicLoading
) ->
  AllItems.by_id $scope, $stateParams.id, (val) ->
    $scope.item = val

  $scope.go_back_to_bag = ->
    $state.go 'tab.bag'

  $scope.get_item_or_recipe = ->
    if $ionicHistory.currentView().stateName.indexOf('recipe') == -1
      'iteminfo'
    else
      'recipeinfo'

  # get all contents, both sub-recipes and foodstuffs
  $scope.get_all_content = (bag) ->
    if bag and bag.contents
      bag.contents.concat bag.contentsLists or []
    else
      []

  # calculate total price for a whole recipe
  # this takes into account any sub-recipes
  # through recursion. Anything checked off won't be taken into account.

  $scope.calculate_total = (bag) ->
    total = 0
    $scope.get_all_content(bag).forEach (item) ->
      if item.checked == true
        return
      else if item.contents
        # this recipe has items of its own
        total += $scope.calculate_total(item) * (parseFloat(item.quantity) or 1)
      else
        # do total
        total += parseFloat(item.price) * (parseFloat(item.quantity) or 1)
      return
    total

  # "like" an item
  $scope.fav_item = (item) ->
    socket.emit 'user:fav', item: item._id
    $scope.favs.push item._id

    # give the user a little "notification" about it
    $ionicLoading.show
      template: 'Favorited "' + item.name + '"!'
      noBackdrop: true
      duration: 2000


  # un-"like" an item
  $scope.un_fav_item = (item) ->
    socket.emit 'user:un_fav', item: item._id
    $scope.favs = _.without($scope.favs, item._id)
    # give the user a little "notification" about it
    $ionicLoading.show
      template: 'Un-Favorited "' + item.name + '"!'
      noBackdrop: true
      duration: 2000
    return

  # is this a favorite item?
  $scope.is_fav = ->
    if $scope.favs and $scope.item
      $scope.favs.indexOf($scope.item._id) != -1
    else
      false

  # are we a favorite?
  user.then (data) ->
    $scope.favs = data.favs
