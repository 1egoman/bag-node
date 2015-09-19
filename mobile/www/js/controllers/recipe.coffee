angular.module('bag.controllers.tab_recipe', [])
  
.controller 'RecipesCtrl', (
  $scope,
  persistant,
  $state,
  $ionicPopup
  user
) ->
  # With the new view caching in Ionic, Controllers are only called
  # when they are recreated or on app start, instead of every page change.
  # To listen for when this page is active (for example, to refresh data),
  # listen for the $ionicView.enter event:
  #
  #$scope.$on('$ionicView.enter', function(e) {
  #});
  #

  ###
  # Choose to add a new foodstuff or a recipe
  ###
  # $ionicModal.fromTemplateUrl('templates/modal-foodstuff-or-recipe.html',
  #   scope: $scope
  #   animation: 'slide-in-up').then (modal) ->
  #   $scope.foodstuff_or_recipe_modal = modal
  #
  # # open the modal to choose between adding a foodstuff or recipe
  # $scope.open_foodstuff_or_recipe_modal = ->
  #   $scope.foodstuff_or_recipe_modal.show()
  #
  # # close the foodstuff vs recipe modal
  # $scope.close_foodstuff_or_recipe_modal = ->
  #   $scope.foodstuff_or_recipe_modal.hide()
  #   return
  #
  # ###
  # # Add a new foodstuff
  # ###
  # $ionicModal.fromTemplateUrl('templates/modal-add-foodstuff.html',
  #   scope: $scope
  #   animation: 'slide-in-up').then (modal) ->
  #   $scope.foodstuff_modal = modal
  #
  # # user wantes to add a new foodstuff
  # # open up a new modal to do that in
  # $scope.open_add_foodstuff_modal = ->
  #   $scope.close_foodstuff_or_recipe_modal()
  #   $scope.foodstuff_modal.show()
  #
  # # close the add foodstuffs modal
  # $scope.close_add_foodstuff_modal = ->
  #   $scope.foodstuff_modal.hide()
  #
  # ###
  # # Add a new recipe
  # ###
  # $ionicModal.fromTemplateUrl('templates/modal-add-recipe.html',
  #   scope: $scope
  #   animation: 'slide-in-up').then (modal) ->
  #   $scope.recipe_modal = modal
  #
  # # user wantes to add a new foodstuff
  # # open up a new modal to do that in
  # $scope.open_add_recipe_modal = ->
  #   $scope.close_foodstuff_or_recipe_modal()
  #   $scope.recipe_modal.show()
  #
  # # close the add foodstuffs modal
  # $scope.close_add_recipe_modal = ->
  #   $scope.recipe_modal.hide()

  ###
  # Manage recipes that are already created by user
  ###

  # send user to more infoabout the specified item
  $scope.more_info = (item) ->
    $state.go 'tab.recipeinfo', id: item._id

  socket.on 'item:index:callback', (evt) ->
    $scope.my_recipes = evt.data

    # create sort opts
    for i in $scope.my_recipes
      $scope.sort_opts[i._id] = $scope.make_sort_opts i

    $scope.$apply()

    # for pull to refresh
    $scope.$broadcast 'scroll.refreshComplete'

  # check to make sure a new user can create more private recipes
  $scope.user_more_private = (user) ->
    if not user
      false
    else if user.plan is 1
      $scope.my_recipes.filter (r) ->
        r.private
      .length < 10
    else if user.plan is 2
      true
    else
      false

  # using an item, create its sorting settings
  $scope.make_sort_opts = (item) ->
    if item.private
      checks: false
      no_quantity: true
    else
      checks: false
      no_quantity: true
      no_delete: true

  # delete a private recipe
  $scope.delete_item = (item) ->
    socket.emit "foodstuff:destroy", foodstuff: item._id
    $scope.my_recipes = _.without $scope.my_recipes, item

  # when a user pulls to refresh...
  $scope.do_refresh = ->
    socket.emit 'item:index', user: 'me'


  ###
  # Initialization
  ###
  $scope.my_recipes = []
  $scope.sort_opts = {}

  user.then (u) ->
    $scope.user = u
    socket.emit 'item:index', user: 'me'
    $scope.$on '$destroy', ->
      $scope.foodstuff_or_recipe_modal.remove()
      $scope.foodstuff_modal.remove()

