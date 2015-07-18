// set up the socket.io conenction
socket = io('http://192.168.1.14:8000/55a84d00e4b06e29cb4eb960', {query: "token=my_token"});
// # socket.emit 'foodstuff:index', list: "55a84255eb8799c52c643830"
//
// # get initial event info from backend
// # socket.emit 'foodstuff:index'
// # socket.on 'foodstuff:index:callback', (event) =>
// #   @push event.data
// #
// # socket.on 'foodstuff:create:callback', (event) =>
// #   @push event.data
// #
// # socket.on 'foodstuff:update:callback', (event) =>
// #   @push event.data
// #
// # socket.on 'foodstuff:delete:callback', (event) =>
// #   @push event.data

// get rid of some of the angular crud
// this is needed when doing client <-> server stuff
strip_$$ = function(a) {
  return angular.fromJson(angular.toJson(a));
};

angular.module('starter.controllers', ['btford.socket-io'])

// inject socket.io into angular
.factory("socket", function (socketFactory) {
  return socketFactory({ioSocket: socket});
})

// Bags Controller
// This manages the bag, which can contain recipes or foodstuffs
.controller('BagsCtrl', function($scope, $ionicModal, $ionicSlideBoxDelegate, $ionicFilterBar, socket) {

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
  $scope.open_add_modal = function() {
    $scope.modal.show();
  };
  $scope.close_add_modal = function() {
    $scope.modal.hide();
  };
  //Cleanup the modal when we're done with it!
  $scope.$on('$destroy', function() {
    $scope.modal.remove();
  });


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
  $scope.flatten_bag = function(bag) {
    bag = bag || $scope.bag
    var total = [];

    bag.contents.concat(bag.contentsLists || []).forEach(function(item) {
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

    console.log(total);
    return total;
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
    $scope.bag = evt.data
  });


  // get all contents, both sub-lists and foodstuffs
  $scope.get_all_content = function(bag) {
    if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else return []
  };

  ////
  // Intializers
  ////
  $scope.change_active_bag(0);
  $scope.filter_open = false
  $scope.filtered_items = []

})


// Add to bags controller
// manages the "add to bags" modal
.controller('AddToBagsCtrl', function($scope, $ionicFilterBar, socket) {

  $scope.all = []
  $scope.all_recipes = []
  $scope.all_foodstuffs = []
  socket.on("lists:index:callback", function(evt) {
    $scope.all = evt.data
  });

  socket.on("foodstuff:index:callback", function(evt) {
    $scope.all_foodstuffs = evt.data
  });





})



// Recipe Card Controller
// This manages each recipe card so that it will always stay up to date.
.controller('RecipeCtrl', function($scope, socket) {

  // calculate total price for a whole recipe
  // this takes into account any sub-recipes
  // through recursion. Anything checked off won't be taken into account.
  $scope.calculate_total = function(bag) {
    var total = 0;
    (bag.contents || []).forEach(function(item) {
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
  // Updating a recipe
  ////

  // check an item on a recipe
  // basically, when an item is checked it doesn't add to any totals
  // because the user is presumed to have bought it already.
  $scope.check_item_on_recipe = function(recipe, item) {
    socket.emit('list:update', {
      list: strip_$$(recipe)
    });
  };
  socket.on('list:update:callback', function(evt) {
    if (evt.data) {
      $scope.recipe = evt.data
    }
  });

  // get all contents, both sub-recipes and foodstuffs
  $scope.get_all_content = function(bag) {
    if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else return []
  };
  ////
  // Intializers
  ////

})

// Recipe List Controller
// Gets a subset of all lists and returns it
.controller('RecipeListCtrl', function($scope, socket, $ionicSlideBoxDelegate) {

  // get all recipes
  // this fires once at the load of the controller, but also repeadedly when
  // any function wants th reload the whole view.
  socket.emit('list:index')
  socket.on('list:index:callback', function(evt){
    // console.log("list:index:callback", evt)
    $scope.recipes = evt.data

    // force the slide-box to update and make
    // each "page" > 0px (stupid bugfix)
    $ionicSlideBoxDelegate.update()
  });
})












.controller('ChatsCtrl', function($scope, Chats) {
  // With the new view caching in Ionic, Controllers are only called
  // when they are recreated or on app start, instead of every page change.
  // To listen for when this page is active (for example, to refresh data),
  // listen for the $ionicView.enter event:
  //
  //$scope.$on('$ionicView.enter', function(e) {
  //});

  $scope.chats = Chats.all();
  $scope.remove = function(chat) {
    Chats.remove(chat);
  };
})

.controller('ChatDetailCtrl', function($scope, $stateParams, Chats) {
  $scope.chat = Chats.get($stateParams.chatId);
})

.controller('AccountCtrl', function($scope) {
  $scope.settings = {
    enableFriends: true
  };
});
