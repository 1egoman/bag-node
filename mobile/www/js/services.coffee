angular.module('bag.services', [
  'bag.services.factory'
  'bag.services.bag'
  'bag.services.recipe'
  'bag.services.foodstuff'
])
  
.factory 'AllItems', (socket, List, Foodstuff) ->
  root = {}
  root.id = {}
  # look through all foodstuffs and items for the specified id

  root.by_id = (sc, id, cb) ->
    sc.id_calls = 0

    List.show
      list: id
    .then (evt) ->
      root.id[id] = evt or root.id[id]
      sc.id_calls++

    Foodstuff.show
      foodstuff: id
    .then (evt) ->
      root.id[id] = evt or root.id[id]
      sc.id_calls++

    sc.$watch 'id_calls', ->
      sc.id_calls == 2 and cb root.id[id]

  # get a reference to all items in db
  # both foodstuffs and recipes
  # sc.start_index is the place to start searching, which defautls to zero
  root.all = (sc, cb) ->
    root.all_resp = []

    List.index
      limit: sc.amount_in_page
      start: sc.start_index or 0
    .then (evt) ->
      root.all_resp = evt.concat(root.all_resp or [])
      sc.all_calls++

    Foodstuff.index
      limit: sc.amount_in_page
      start: sc.start_index or 0
    .then (evt) ->
      root.all_resp = evt.concat(root.all_resp or [])
      sc.all_calls++

    sc.all_calls = 0

    sc.$watch 'all_calls', ->
      sc.all_calls == 2 and cb(root.all_resp)


  # given a search string, find all matching lists and foodstuffs
  root.search = (sc, search_str, cb) ->
    sc.id_calls = 0


    List.search
      list: search_str
    .then (evt) ->
      root.id[id] = evt or root.id[id]
      sc.id_calls++

    Foodstuff.search
      foodstuff: search_str
    .then (evt) ->
      root.id[id] = evt or root.id[id]
      sc.id_calls++

    sc.$watch 'id_calls', ->
      sc.id_calls == 2 and cb root.id[id]




  # return factory reference
  root


# persistant caching of stuff between controllers and their instances
.factory 'persistant', ->
    sort: null
    sort_opts: {}


# using the specified user id, return the user object
.factory 'userFactory', ($q, socket) ->
  (user_id) ->
    defer = $q.defer()
    socket.emit 'user:show', user: user_id
    socket.on 'user:show:callback', (evt) ->
      window.user = evt.data # hack so we can use user in sync stuff (yea, I know, there are a lot of issues with this, but it works for now. Used in pickPrice.)
      defer.resolve evt.data
      return
    defer.promise

  
# ionic filter bar wrapper that makes working with it sane
.factory 'searchItem', ($ionicFilterBar) ->
  (all_items, update_cb) ->
    $scope = {}

    $scope.open = (on_close) ->
      $scope.hide = $ionicFilterBar.show(
        items: all_items
        update: (filteredItems) ->
          all_items = filteredItems
          update_cb and update_cb(all_items)
        cancel: ->
          on_close and on_close()
        filterProperties: 'name')

    $scope



# calculate total price for a whole bag
# this takes into account any sub-recipes
# through recursion.
.factory 'calculateTotal', (pickPrice, user) ->
  # get all contents, both sub-lists and foodstuffs
  # this lets us recurively wander
  get_all_content = (bag, return_self) ->
    if bag.length
      bag
    else if bag and bag.contents
      bag.contents.concat bag.contentsLists or []
    else
      if return_self then [ bag ] else []

  calculate_total = (bag) ->
    total = 0
    get_all_content(bag, true).forEach (item) ->
      return 0 if not item # callbacks haven't resolved yet

      if item.checked == true
        return 0

      else if item.contents
        # this recipe has items of its own
        total += calculate_total(item) * (parseFloat(item.quantity) or 1)

      else
        # do total
        total += pickPrice(item) * (parseFloat(item.quantity) or 1)

    return total

  calculate_total


# pick the correct price for an item
# if a store is specified, go with that
# otherwise, ik the minimum price
.factory 'pickPrice', ->
  (item, user=window.user) ->
    return if not user

    # a store was specified
    # if we don't have to calculate the store, we may as well use the one
    # specified.
    if item.store and item.stores and item.stores[item.store] and item.store in user.stores
      item.stores[item.store].price

     # we'll pick the best store with the lowest price from a user's stores
    else if item.stores and user and user.stores.length
      possible_stores = _.mapObject item.stores, (v, k) -> v.price

      # do an intersection (of objects!) between the item's stores and the
      # user's stores to try and find commonalities
      # pickable_stores = _(possible_stores).chain().map (ea) ->
      #   return _.find(user.stores, (eb) -> ea.id == eb or ea.id == eb.id)
      # .compact().value()
      
      pickable_stores = _.mapObject possible_stores, (v, ea) ->
        ea in user.stores
      pickable_stores = _.keys pickable_stores
      
      # which store to choose? How about the first one? Or if that doesn't work,
      # lets just go with the item's first store.
      price = _.min(pickable_stores.map (s) ->
        item.stores[s].price
      ) or _.min _.mapObject item.stores, (v, k) -> v.price # well, or just find a price.....

      # set this store for next time
      store = _.invert(possible_stores)[price]
      item.store = store if store

      price

    else
      item.store = null
      item.price or 0 # well, we give up?


# get a reference to all stores
.factory 'stores', (socket, $q) ->
    defer = $q.defer()
    socket.emit "store:index"
    socket.on "store:index:callback", (evt) ->
      stores = {}
      for item in evt.data
        stores[item._id] = item
      defer.resolve stores
      return
    defer.promise

# store chooser
.factory "storePicker", ($ionicModal, $q, stores, user, $state, $timeout, $cordovaDialogs) ->
  ($scope, item) ->

    initial_p = $q.defer()
    p = $q.defer()

    # the model instansiator
    $scope.store_picker_modal = null
    $ionicModal.fromTemplateUrl 'templates/model-pick-store.html',
      scope: $scope,
      animation: 'slide-in-up'
    .then (m) ->
      $scope.store_picker_modal = m

      # get stores, and at those to the $scope below
      stores.then (s) ->
        user.then (u) ->
          $scope.store_picker.stores = _.compact _.map u.stores, (v) ->
            if $scope.item.stores and $scope.item.stores[v]
              obj = s[v]
              obj.price_for_item = $scope.item.stores[v].price # add the price
              obj

          # resolve the intial promise, which will return methods to interact with
          # the store picker modal
          initial_p.resolve
            choose: ->
              $scope.store_picker_modal.show()
              p.promise

            close: ->
              $scope.store_picker_modal.hide()

 
    # these methods are called within the view to choose a store or dismiss one.
    $scope.store_picker =

      user: null

      pick_store: (item) ->
        p.resolve item
        $scope.store_picker_modal.hide()

      dismiss: ->
        p.resolve null
        $scope.store_picker_modal.hide()

      # change to stores picker so user can add stores to their list
      to_stores_picker: ->
        @dismiss()
        $state.go "tab.account"
        $timeout ->
          $state.go "tab.stores"
        , 100

      # switch to the custom price view
      to_custom_price: ->
        @do_custom_price = true

      # add a store to the list of stores, and select that store.
      custom_price: (price) ->
        $scope.item.stores or= {}
        $scope.item.stores["custom"] =
          price: parseFloat price
        @pick_store _id: "custom"

      # switch to the suggest store view
      to_suggest_store: ->
        @do_suggest_store = true

      suggest_store: (store) ->
        console.log store
        socket.emit "store:suggest", store
        socket.on "store:suggest:callback", (evt) ->
          console.log evt
          if evt.resolves_to
            @pick_store evt.resolves_to
          else
            $cordovaDialogs.alert "We'll take a look at this and add it soon.", "Thanks", "OK"
            $scope.store_picker_modal.hide()


    user.then (u) -> $scope.store_picker.user = u

    $scope.$on '$destroy', ->
      $scope.store_picker_modal.remove()

    initial_p.promise


# given a partial tag name, return a promise that will resolve to all matching
# tag names for that query.
.factory "getTagsForQuery", (socket, $q) ->
  (query) ->
    defer = $q.defer()
    socket.emit 'tag:show', tag: query
    socket.once 'tag:show:callback', (evt) ->
      defer.resolve evt.data
    defer.promise
