angular.module 'starter.controllers.new_recipe', []

.controller 'NewRecipeCtrl', (
  $scope,
  socket,
  $ionicModal,
  AllItems,
  searchItem,
  $q
) ->

  # new item modal of adding items to the recipe
  $ionicModal.fromTemplateUrl('templates/modal-add-to-bag.html',
    scope: $scope
    animation: 'slide-in-up').then (modal) ->
    $scope.item_modal = modal

  # tags to search through
  $scope.predefined_tags = (query) ->
    defer = $q.defer()
    socket.emit 'tags:index'
    socket.once 'tags:index:callback', (evt) ->
      defer.resolve evt.data
    defer.promise

  # create a new foodstuff
  $scope.create_recipe = (name, tags, desc) ->
    # filter recipe_contents into contents and contentsLists
    r_contents = []
    r_contentsLists = []
    $scope.recipe_contents.forEach (i) ->
      if i.contents
        r_contentsLists.push i
      else
        r_contents.push i
      return
    $scope.recipe_contents = []

    # assemble the recipe
    recipe =
      name: name
      desc: desc
      tags: (tags or []).map (i) -> i.text
      contents: window.strip_$$(r_contents)
      contentsLists: strip_$$(r_contentsLists)

    # make the request
    socket.emit 'list:create', list: recipe

  # we got a callback!
  socket.on 'list:create:callback', (evt) ->
    # console.log(evt.data)
    $scope.confirmed = evt.data

  # add a new item to the new recipe
  $scope.open_add_item_modal = ->
    $scope.item_modal.show()
    # get all items and display in the search
    AllItems.all $scope, (content) ->
      $scope.add_items = content

  # add the item to the recipe
  # I know, misleading method name
  $scope.add_item_to_bag = (item) ->
    $scope.recipe_contents.push item

    # close modal
    $scope.close_add_modal()
    $scope.add_search and $scope.add_search.hide()

  # close the add item modal
  $scope.close_add_modal = ->
    $scope.item_modal.hide()
    $scope.add_search and $scope.add_search.hide()

  # open search on the add new items modal
  $scope.open_search = ->
    $scope.add_search = searchItem $scope.add_items, (filtered_items) ->
      $scope.add_items = filtered_items
    $scope.add_search.open()

  # cleanup the modal when we're done with it
  $scope.$on '$destroy', ->
    $scope.item_modal.remove()

  ###
  # Initialization
  ###

  $scope.init = ->
    $scope.confirmed = null
    $scope.recipe_contents = []

  $scope.init()
