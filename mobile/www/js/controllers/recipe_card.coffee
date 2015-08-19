angular.module('starter.controllers.recipe_card', [])
  
.controller 'RecipeCtrl', (
  $scope,
  socket,
  $state,
  $location,
  $sce,
  $sanitize
  calculateTotal
) ->

  # calculate total price for a whole recipe
  # this takes into account any sub-recipes
  # through recursion. Anything checked off won't be taken into account.
  $scope.calculate_total = calculateTotal

  ###
  # Updating a recipe
  ###
  # check an item on a recipe
  # basically, when an item is checked it doesn't add to any totals
  # because the user is presumed to have bought it already.

  $scope.check_item_on_recipe = (recipe, item) ->
    socket.emit 'list:update', list: window.strip_$$(recipe)

  socket.on 'list:update:callback', (evt) ->
    if evt.data
      $scope.recipe = evt.data

  # get all contents, both sub-recipes and foodstuffs
  $scope.get_all_content = (bag) ->
    if bag and bag.contents
      bag.contents.concat bag.contentsLists or []
    else
      []

  # format the name of a list
  # shrink down the text size when the name is too long
  $scope.format_name = (n) ->
    if window.innerWidth > 200 + 10 * n.length
      n
    else
      $sce.trustAsHtml '<span style=\'font-size: 75%;\'>' + $sanitize(n) + '</span>'

  ###
  # Intializers
  ###
