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
  calculateTotal
  stores
  storePicker
) ->


  # are we viewing a bag item or a recipe that is seperate?
  $scope.get_item_or_recipe = ->
    if $ionicHistory.currentView().stateName.indexOf('recipe') == -1
      'iteminfo'
    else
      'recipeinfo'


  # what is our store?
  # once resolved, we'll use this to display the store next to the price
  $scope.get_store_details = ->

    # a custom price
    if $scope.item?.store is "custom"
      $scope.store =
        _id: "custom"
        name: "Custom Price"
        desc: "User-created price"
        image: "https://cdn1.iconfinder.com/data/icons/basic-ui-elements-round/700/06_ellipsis-512.png"

    # a registered store
    else if $scope.item?.store
      stores.then (s) ->
        $scope.store = s[$scope.item.store]

    # no store
    else
      $scope.store =
        name: "No Store"
        desc: "Please choose a store."




  if $scope.get_item_or_recipe() is 'recipeinfo'
    # since we are a recipe, log a "click" to the backend
    socket.emit "user:click", recipe: $scope.item._id


  # an item in the bag, so lets find it within the bag
  user.then (usr) ->
    socket.emit "bag:index", user: usr._id
    socket.on "bag:index:callback", (bag) ->
      $scope.bag = bag.data

      # for each matching item (recipe's don't have stores), find the
      # most likely store to match the specified item id
      # this is done by traversing the bag's tree recursively
      to_level = (haystack=$scope.bag) ->

        # concat together the lists and the foodstuffs into one big array
        list_contents = (haystack.contentsLists or []).map (i) -> i.contents
        flattened = list_contents.concat(haystack.contents).concat(haystack.contentsLists or [])
        for needle in flattened
          if needle and needle._id is $stateParams.id

            # hey, we got it!
            $scope.item = needle
            
            # lets update the store info while we're at it
            $scope.get_store_details()

            break
          else if needle
            to_level needle
      to_level()

      # lastly, if we don't have anthing at this point it isn't an item. Let's
      # just look it up.
      if not $scope.item
        AllItems.by_id $scope, $stateParams.id, (val) ->
          $scope.item = val

          # methods that will be called below that don't acctually do anything in
          # this mode.
          $scope.get_store_details = ->




  # move back to the bag view
  $scope.go_back_to_bag = ->
    $state.go 'tab.bag'

  # change the quantity, used by the big + and - buttons
  $scope.set_item_quantity = (item, quant) ->
    item.quantity = quant

    # also, find the correct item and update the bag
    $scope.find_in_bag item._id, (item) -> item.quantity = quant
    socket.emit 'bag:update', bag: window.strip_$$($scope.bag)


  # find an item in the bag, and run a function passing in the item.
  $scope.find_in_bag = (id, cb) ->

    # for each matching item (recipe's don't have stores), update the
    # store to the specified one
    # this is done by traversing the bag's tree recursively
    to_level = (haystack=$scope.bag) ->

      # concat together the lists and the foodstuffs into one big array
      list_contents = (haystack.contentsLists or []).map (i) -> i.contents
      for needle in list_contents.concat(haystack.contents)
        if needle and needle._id is id
          cb needle
          break
        else if needle
          to_level needle
    to_level()



  # open the store chooser so the user can pick a store for our item
  $scope.open_store_chooser = ->
    storePicker($scope).then (store) -> store.choose().then (resp) ->
      if resp
        # set the store id, re-fetch the store info, and save it to the database
        $scope.item.store = resp._id
        $scope.get_store_details()

        # find the item in the bag, and set the store information
        $scope.find_in_bag $scope.item._id, (item) -> item.store = resp._id

        # and propagate the change
        socket.emit 'bag:update', bag: window.strip_$$($scope.bag)


  # get all contents, both sub-recipes and foodstuffs
  $scope.get_all_content = (bag) ->
    if bag and bag.contents
      bag.contents.concat bag.contentsLists or []
    else
      []

  # calculate total price for a whole recipe
  # this takes into account any sub-recipes
  # through recursion. Anything checked off won't be taken into account.
  $scope.calculate_total = calculateTotal

  # "like" an item
  $scope.fav_item = (item) ->
    socket.emit 'user:fav', item: item._id
    $scope.favs.push item._id

    # give the user a little "notification" about it
    $ionicLoading.show
      template: 'Favorited "' + item.name + '"!'
      noBackdrop: true
      duration: 750


  # un-"like" an item
  $scope.un_fav_item = (item) ->
    socket.emit 'user:un_fav', item: item._id
    $scope.favs = _.without($scope.favs, item._id)

    # give the user a little "notification" about it
    $ionicLoading.show
      template: 'Un-Favorited "' + item.name + '"!'
      noBackdrop: true
      duration: 750

  # is this a favorite item?
  $scope.is_fav = ->
    if $scope.favs and $scope.item
      $scope.favs.indexOf($scope.item._id) != -1
    else
      false

  # are we a favorite?
  user.then (data) ->
    $scope.favs = data.favs

  ###
  # Initializers
  ###
  $scope.store = {}
