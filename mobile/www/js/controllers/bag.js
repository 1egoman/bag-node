
angular.module('starter.controllers.tab_bag', [])

// Bags Controller
// This manages the bag, which can contain recipes or foodstuffs
.controller('BagsCtrl', function(
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
) {

  // get all bags
  // this fires once at the load of the controller, but also repeadedly when
  // any function wants th reload the whole view.
  socket.emit('bag:index')
  socket.on('bag:index:callback', function(evt){
    // console.log("bag:index:callback", evt)
    $scope.bag = evt.data

    // force the slide-box to update and make
    // each "page" > 0px (stupid bugfix)
    $ionicSlideBoxDelegate.update()

    // updating the sorting for the bag
    $scope.sorted_bag = $scope.sort_items()
  });

  // calculate total price for a whole bag
  // this takes into account any sub-recipes
  // through recursion.
  $scope.calculate_total = function(bag) {
    var total = 0;
    $scope.get_all_content(bag, true).forEach(function(item) {
      if (item.checked === true) {
        return
      } else if (item.contents) {
        // this recipe has items of its own
        total += $scope.calculate_total(item) * (parseFloat(item.quantity) || 1)
      } else {
        // do total
        total += parseFloat(item.price) * (parseFloat(item.quantity) || 1)
      }
    });
    return total;
  };

  // for an entire section, calculate the total
  $scope.calculate_total_section = function(items) {
    return _(items).map(function(i) {
      return $scope.calculate_total(i) * i.quantity
    }).reduce(function(m,x) { return m + x }, 0)
  }


  ////
  // Create new item
  ////
  $ionicModal.fromTemplateUrl('templates/modal-add-to-bag.html', {
    scope: $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    $scope.modal = modal;
  });

  // user wantes to add a new item
  $scope.open_add_modal = function() {
    $scope.modal.show();
  };

  // infinte scroll handler to add more items to the list
  // this is also called right away and preloads the list at first
  $scope.on_load_more_add_items = function(page_size) {
    if ($scope.add_items_done) return // make sure we don't overstep bounds

    AllItems.all($scope, function(items) {
      $scope.add_items = $scope.add_items.concat(items)
      $scope.start_index += (page_size || $scope.amount_in_page)

      // update view
      if (items.length < $scope.amount_in_page) $scope.add_items_done = true
      $scope.$broadcast('scroll.infiniteScrollComplete')
    })
    
  }

  // filter with ionic filter bar
  $scope.open_search = function() {
    search = searchItem($scope.add_items, function(filtered_items) {
      $scope.add_items = filtered_items
    })
    search.open()
    $scope.hide_search = search.hide
  }

  // close the add modal
  $scope.close_add_modal = function() {
    $scope.modal.hide();
    $scope.hide_search && $scope.hide_search();
  };
  // cleanup the modal when we're done with it
  $scope.$on('$destroy', function() {
    $scope.modal.remove();
  });

  // add a new item to the bag
  $scope.add_item_to_bag = function(item) {

    // set quantity to one, for an initial new item
    item.quantity = 1

    // is the item currently in the bag?
    item_in_bag = _($scope.get_all_content($scope.bag))
    .find(function(i) { return i._id === item._id; })

    // if so, just increment the quantity
    if ( item_in_bag && item_in_bag.length !== 0 ) {
      item_in_bag.quantity = (item_in_bag.quantity || 0) + 1

    // otherwise, just add it
    } else if (item.contents) {
      // make sure everything inside is unchecked
      // if this isn't done sometimes items will "gitch" into
      // the complete section
      item.contents.forEach(function(i) { i.checked = false  })

      $scope.bag.contentsLists.push(item)
    } else {
      $scope.bag.contents.push(item)
    }

    // update everything!
    $scope.update_bag()
    $scope.close_add_modal()
  }





  ////
  // View mechanics
  ////

  // is the user currently viewing the bag?
  $scope.is_viewing_bag = function() {
    return $scope.active_card === 0
  };

  // use ionic filter bar to filter through the bag
  $scope.filter_bag_contents = function() {
    $scope.filter_open = true
    searchItem($scope.flatten_bag(), function(filtered_items) {
      $scope.filtered_items = filtered_items
    }).open(function() {
      // runs on close
      $scope.filtered_items = []
      $scope.filter_open = false
    })
  }

  // flatten the bag so everything is easily indexable
  // this is used for search
  $scope.flatten_bag = function(bag, opts) {
    bag = bag || $scope.bag
    opts = opts || {}
    if (!bag) return
    var total = [];

    (bag.contents || []).concat(bag.contentsLists || []).forEach(function(item) {
      if (item.contents) {
        // this recipe has items of its own
        total = total.concat($scope.flatten_bag(item, opts))
        if (opts.list_names_index === false) total.push(item);
      } else {
        // do total
        total.push(item)
      }
    });
    return total;
  }

  // get all contents, both sub-lists and foodstuffs
  // this lets us recurively wander
  $scope.get_all_content = function(bag, return_self) {
    if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else return return_self ? [bag] : []
  };

  // get all checkmarked items
  // this is used to place those items in the "completed" section
  $scope.get_marked_items = function(bag) {
    marked = $scope.get_all_content(bag).filter(function(b) {
      return b.checked || (b.contents && $scope.all_checked(b))
    })

    return marked;
  }

  // are all items within a specific item all checked?
  $scope.all_checked = function(item) {
    return $scope.get_all_content(item).map(function(item) {
      if (item.contents || item.contentsLists) {
        // this recipe has items of its own
        return $scope.all_checked(item);
      } else {
        // do total
        return item.checked;
      }
    }).indexOf(false) === -1
  };

  // transistion to a more info page about the specified item
  $scope.more_info = function(item) {
    $ionicListDelegate.closeOptionButtons()
    $state.go('tab.iteminfo', {id: item._id})
  }






  ////
  // Updating a bag
  ////

  // update a bag
  // basically, when an item is checked it doesn't add to any totals
  // because the user is presumed to have bought it already.
  $scope.update_bag = function() {
    socket.emit('bag:update', {
      bag: strip_$$($scope.bag)
    });
  };
  socket.on("bag:update:callback", function(evt) {
    // update the bag
    $scope.bag = evt.data

    // updating the sorting for the bag
    $scope.sorted_bag = $scope.sort_items()
  });



  ////
  // Deleting an item in a bag
  ////

  $scope.delete_item = function(item) {
    $scope.bag.contents = $scope.bag.contents.filter(function(i) {
      return i._id !== item._id
    })
    $scope.bag.contentsLists = $scope.bag.contentsLists.filter(function(i) {
      return i._id !== item._id
    })
    $scope.update_bag()
  }



  ////
  // switching to list mode
  ////

  $scope.to_list_mode = function() {
    $state.go("tab.select")
  }
  $rootScope.$on('$stateChangeSuccess', function(event, toState) {
    if (toState.name === "tab.bag") {
      $scope.sorted_bag = $scope.sort_items()
      $scope.sort_opts = persistant.sort_opts
    }
  })


  ////
  // Sorting types
  ////

  $scope.sort_items = function(bag) {
    items = $scope.get_all_content(bag || $scope.bag);
    switch (persistant.sort) {

      // sort by checked/still left
      case "completion":
        persistant.sort_opts = $scope.sort_opts = {}
        return _.groupBy(items, function(i) {
          if (i.checked || (i.contents && $scope.all_checked(i))) {
            return "Mutated";
          } else {
            return "In my bag";
          }
        })

      // sort by sort tags
      case "tags":
        persistant.sort_opts = $scope.sort_opts = {checks: true}
        return _.groupBy(items, function(i) {
          return _.find(i.tags, function(x) { return x.indexOf('sort-') !== -1;  }) || 'No sort';
        });

      // sort by sort tags, and seperate into each of its contents
      case "tags_list":
        persistant.sort_opts = $scope.sort_opts = {checks: true}
        return _.groupBy($scope.flatten_bag(), function(i) {
          return _.find(i.tags, function(x) { return x.indexOf('sort-') !== -1;  }) || 'No sort';
        });

      // no sort
      default:
        persistant.sort_opts = $scope.sort_opts = {}
        return {"All Items": items};
        break;
    }
  }

  // update the old sort to the specified one
  $scope.change_sort = function(new_sort_name) {
    persistant.sort = new_sort_name
    $scope.sort_opts = persistant.sort_opts 
    $scope.sorted_bag = $scope.sort_items()
  }



  ////
  // Intializers
  ////
  $scope.filter_open = false
  $scope.filtered_items = []
  $scope.completed_items = []
  $scope.echo = function() {console.log("Called!"); return "Called!"}

  $scope.sort_type = persistant.sort || 'no'
  $scope.sorted_bag = []

  $scope.view_title = "My Bag"
  $scope.sort_opts = persistant.sort_opts || {}

  $scope.add_items = []
  $scope.start_index = 0
  $scope.add_items_done = false
  $scope.amount_in_page = 25

})


