
angular.module('starter.controllers')

// Bags Controller
// This manages the bag, which can contain recipes or foodstuffs
.controller('BagsCtrl', function(
      $scope, 
      $ionicModal, 
      $ionicSlideBoxDelegate, 
      $ionicFilterBar, 
      socket, 
      $state,
      $ionicListDelegate,
      AllItems
) {

  // get all bags
  // this fires once at the load of the controller, but also repeadedly when
  // any function wants th reload the whole view.
  socket.emit('bag:index')
  socket.on('bag:index:callback', function(evt){
    // console.log("bag:index:callback", evt)
    $scope.bag = evt.data

    // update the marked items
    $scope.completed_items = $scope.get_marked_items($scope.bag)

    // force the slide-box to update and make
    // each "page" > 0px (stupid bugfix)
    $ionicSlideBoxDelegate.update()
  });

  // calculate total price for a whole bag
  // this takes into account any sub-recipes
  // through recursion.
  $scope.calculate_total = function(bag) {
    var total = 0;
    bag.contents.forEach(function(item) {
      if (item.contents) {
        // this recipe has items of its own
        total += $scope.calculate_total(item);
      } else if (item.checked !== true) {
        // do total
        total += item.price
      }
    });
    return total;
  };


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

    // get all items and display in the search
    AllItems.all($scope, function(content) {

      // filter with ionic filter bar
      $scope.hide_filter_bar = $ionicFilterBar.show({
        items: content,
        done: function() {
          $scope.add_items = content
        },
        update: function (filteredItems) {
          $scope.add_items = filteredItems;
          console.log($scope.add_items)
        },

        // if the filter bar closes, close the modal
        cancel: function() {
          $scope.modal.hide();
        },
        filterProperties: 'name'
      });

    })
  };

  // if modal closes first, close the filter bar
  $scope.close_add_modal = function() {
    $scope.modal.hide();
    $scope.hide_filter_bar()
  };
  // cleanup the modal when we're done with it
  $scope.$on('$destroy', function() {
    $scope.modal.remove();
  });

  // add a new item to the bag
  $scope.add_item_to_bag = function(item) {
    if (item.contents) {
      $scope.bag.contentsLists.push(item)
    } else {
      $scope.bag.contents.push(item)
    }
    $scope.update_bag()
    $scope.close_add_modal()
  }





  ////
  // View mechanics
  ////

  // when a user changes the bag they are looking at, update the title
  $scope.change_active_bag = function(index) {
    $scope.active_card = index
    if (index === 0) {
      $scope.view_title = "My Bag"
    } else {
      $scope.view_title = "My Recipes"//$scope.bags[index-1].name
    }
  };

  // is the user currently viewing the bag?
  $scope.is_viewing_bag = function() {
    return $scope.active_card === 0
  };

  // use ionic filter bar to filter through the bag
  $scope.filter_bag_contents = function() {
    $scope.filter_open = true
    filterBarInstance = $ionicFilterBar.show({
      items: $scope.flatten_bag(),
      update: function (filteredItems) {
        $scope.filtered_items = filteredItems;
      },
      done: function() { $scope.filtered_items = [] },
      cancel: function() { $scope.filtered_items = []; $scope.filter_open = false },
      filterProperties: 'name'
    });
  }

  // flatten the bag so everything is easily indexable
  // this is used for search
  $scope.flatten_bag = function(bag) {
    bag = bag || $scope.bag
    var total = [];

    (bag.contents || []).concat(bag.contentsLists || []).forEach(function(item) {
      console.log(item);
      if (item.contents) {
        // this recipe has items of its own
        total = total.concat($scope.flatten_bag(item))
        total.push(item);
      } else {
        // do total
        total.push(item)
      }
    });
    return total;
  }

  // get all contents, both sub-lists and foodstuffs
  // this lets us recurively wander
  $scope.get_all_content = function(bag) {
    if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else return []
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
    $state.go('iteminfo', {id: item._id})
  }






  ////
  // Updating a bag
  ////

  // update a bag
  // basically, when an item is checked it doesn't add to any totals
  // because the user is presumed to have bought it already.
  $scope.update_bag = function() {
    // update the marked items when you mess with the bag
    $scope.completed_items = $scope.get_marked_items($scope.bag)

    socket.emit('bag:update', {
      bag: strip_$$($scope.bag)
    });
  };
  socket.on("bag:update:callback", function(evt) {
    // update the bag
    $scope.bag = evt.data

    // update the marked items when somebody else messes eith the bag
    $scope.completed_items = $scope.get_marked_items($scope.bag)
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
  // Intializers
  ////
  $scope.change_active_bag(0);
  $scope.filter_open = false
  $scope.filtered_items = []
  $scope.completed_items = []
  $scope.echo = function() {console.log("Called!"); return "Called!"}

})


