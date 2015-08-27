angular.module('starter.controllers.tab_bag', [])
  
.controller 'BagsCtrl', (
  $scope,
  $ionicModal,
  $ionicSlideBoxDelegate,
  socket,
  $state,
  $ionicListDelegate,
  AllItems,
  $timeout,
  persistant,
  $rootScope,
  searchItem
  calculateTotal
  pickPrice
) ->
  # get all bags
  # this fires once at the load of the controller, but also repeadedly when
  # any function wants th reload the whole view.
  socket.emit 'bag:index'
  socket.on 'bag:index:callback', (evt) ->
    # console.log("bag:index:callback", evt)
    $scope.bag = evt.data

    # force the slide-box to update and make
    # each "page" > 0px (stupid bugfix)
    $ionicSlideBoxDelegate.update()

    # updating the sorting for the bag
    $scope.sorted_bag = $scope.sort_items()

  # calculate total price for a whole bag
  # this takes into account any sub-recipes
  # through recursion.
  $scope.calculate_total = calculateTotal

  # for an entire section, calculate the total
  $scope.calculate_total_section = (items) ->
    _(items).map((i) ->
      price: $scope.calculate_total i
      ref: i
    ).reduce ((m, x) ->
      m + x.price * x.ref.quantity # account for both price and quantity
    ), 0

  # using the speicified item, calculate the lowest possible price
  # using the user's stores
  $scope.get_lowest_price = (item) -> calculateTotal item

  ###
  # Create new item
  ###
  $ionicModal.fromTemplateUrl 'templates/modal-add-to-bag.html',
    scope: $scope
    animation: 'slide-in-up'
  .then (modal) ->
    $scope.modal = modal

  # user wantes to add a new item
  $scope.open_add_modal = ->
    $scope.modal.show()

  # infinte scroll handler to add more items to the list
  # this is also called right away and preloads the list at first

  $scope.on_load_more_add_items = (page_size) ->
    return if $scope.add_items_done

    # make sure we don't overstep bounds
    AllItems.all $scope, (items) ->
      $scope.add_items = $scope.add_items.concat(items)
      $scope.start_index += page_size or $scope.amount_in_page
      # update view
      if items.length < $scope.amount_in_page
        $scope.add_items_done = true
      $scope.$broadcast 'scroll.infiniteScrollComplete'

  # filter with ionic filter bar
  $scope.open_search = ->
    search = searchItem $scope.add_items, (filtered_items) ->
      $scope.add_items = filtered_items

    search.open()
    $scope.hide_search = search.hide

  # close the add modal
  $scope.close_add_modal = ->
    $scope.modal.hide()
    $scope.hide_search and $scope.hide_search()

  # cleanup the modal when we're done with it
  $scope.$on '$destroy', ->
    $scope.modal.remove()

  # add a new item to the bag
  $scope.add_item_to_bag = (item) ->

    # set quantity to one, for an initial new item
    item.quantity = 1

    # is the item currently in the bag?
    item_in_bag = _($scope.get_all_content($scope.bag)).find (i) ->
      i._id == item._id

    # if so, just increment the quantity
    if item_in_bag and item_in_bag.length != 0
      item_in_bag.quantity = (item_in_bag.quantity or 0) + 1

    # otherwise, just add it
    else if item.contents

      # make sure everything inside is unchecked
      # if this isn't done sometimes items will "glitch" into
      # the complete section
      item.contents.forEach (i) ->
        i.checked = false

      $scope.bag.contentsLists.push item
    else
      $scope.bag.contents.push item

    # update everything!
    $scope.update_bag()
    $scope.close_add_modal()

  ###
  # View mechanics
  ###
  # is the user currently viewing the bag?
  $scope.is_viewing_bag = ->
    $scope.active_card == 0

  # use ionic filter bar to filter through the bag

  $scope.filter_bag_contents = ->
    $scope.filter_open = true
    searchItem $scope.flatten_bag(), (filtered_items) ->
      $scope.filtered_items = filtered_items
    .open ->
      # runs on close
      $scope.filtered_items = []
      $scope.filter_open = false


  # flatten the bag so everything is easily indexable
  # this is used for search
  $scope.flatten_bag = (bag, opts) ->
    bag = bag or $scope.bag
    opts = opts or {}
    if !bag
      return
    total = []
    (bag.contents or []).concat(bag.contentsLists or []).forEach (item) ->
      if item.contents
        # this recipe has items of its own
        total = total.concat($scope.flatten_bag(item, opts))
        if opts.list_names_index == false
          total.push item
      else
        # do total
        total.push item
      return
    total

  # get all contents, both sub-lists and foodstuffs
  # this lets us recurively wander
  $scope.get_all_content = (bag, return_self) ->
    if bag and bag.contents
      bag.contents.concat bag.contentsLists or []
    else
      if return_self then [ bag ] else []

  # get all checkmarked items
  # this is used to place those items in the "completed" section
  $scope.get_marked_items = (bag) ->
    marked = $scope.get_all_content(bag).filter (b) ->
      b.checked or b.contents and $scope.all_checked(b)
    marked

  # are all items within a specific item all checked?
  $scope.all_checked = (item) ->
    $scope.get_all_content(item).map (item) ->
      if item.contents or item.contentsLists
        # this recipe has items of its own
        $scope.all_checked item
      else
        # do total
        item.checked
    .indexOf(false) == -1

  # transistion to a more info page about the specified item
  $scope.more_info = (item) ->
    $ionicListDelegate.closeOptionButtons()
    $state.go 'tab.iteminfo',
      id: item._id

  ###
  # Updating a bag
  ###
  # update a bag
  # basically, when an item is checked it doesn't add to any totals
  # because the user is presumed to have bought it already.
  $scope.update_bag = ->
    socket.emit 'bag:update', bag: window.strip_$$($scope.bag)

  socket.on 'bag:update:callback', (evt) ->
    # update the bag
    $scope.bag = evt.data
    # updating the sorting for the bag
    $scope.sorted_bag = $scope.sort_items()

  ###
  # Deleting an item in a bag
  ###

  $scope.delete_item = (item) ->
    $scope.bag.contents = $scope.bag.contents.filter((i) ->
      i._id != item._id
    )
    $scope.bag.contentsLists = $scope.bag.contentsLists.filter((i) ->
      i._id != item._id
    )
    $scope.update_bag()
    return

  ###
  # switching to list mode
  ###

  $scope.to_list_mode = ->
    $state.go 'tab.select'

  $rootScope.$on '$stateChangeSuccess', (event, toState) ->
    if toState.name == 'tab.bag'
      $scope.sorted_bag = $scope.sort_items()
      $scope.sort_opts = persistant.sort_opts

  ###
  # Sorting types
  ###

  $scope.sort_items = (bag) ->
    items = $scope.get_all_content(bag or $scope.bag)
    switch persistant.sort

      # sort by checked/still left
      when 'completion'
        persistant.sort_opts = $scope.sort_opts = {}
        return _.groupBy(items, (i) ->
          if i.checked or i.contents and $scope.all_checked(i)
            'Mutated'
          else
            'In my bag'
        )

      # sort by sort tags
      when 'tags'
        persistant.sort_opts = $scope.sort_opts = checks: true
        return _.groupBy(items, (i) ->
          _.find(i.tags, (x) ->
            x.indexOf('sort-') != -1
          ) or 'No sort'
        )

      # sort by sort tags, and seperate into each of its contents
      when 'tags_list'
        persistant.sort_opts = $scope.sort_opts = checks: true
        return _.groupBy($scope.flatten_bag(), (i) ->
          _.find(i.tags, (x) ->
            x.indexOf('sort-') != -1
          ) or 'No sort'
        )

      # no sort
      else
        persistant.sort_opts = $scope.sort_opts = {}
        return { 'All Items': items }
        break
    return

  # update the old sort to the specified one
  $scope.change_sort = (new_sort_name) ->
    persistant.sort = new_sort_name
    $scope.sort_opts = persistant.sort_opts
    $scope.sorted_bag = $scope.sort_items()

  ###
  # Intializers
  ###
  $scope.filter_open = false
  $scope.filtered_items = []
  $scope.completed_items = []

  $scope.echo = ->
    console.log 'Called!'
    'Called!'

  $scope.sort_type = persistant.sort or 'no'
  $scope.sorted_bag = []
  $scope.view_title = 'My Bag'
  $scope.sort_opts = persistant.sort_opts or {}
  $scope.add_items = []
  $scope.start_index = 0
  $scope.add_items_done = false
  $scope.amount_in_page = 25
