// set up the socket.io conenction
socket = io('http://192.168.1.13:8000/55a84d00e4b06e29cb4eb960', {query: "token=my_token"});
// # socket.emit 'foodstuff:index', list: "55a84255eb8799c52c643830"

// get rid of some of the angular crud
// this is needed when doing client <-> server stuff
strip_$$ = function(a) {
  return angular.fromJson(angular.toJson(a));
};

angular.module('starter.controllers', ['btford.socket-io', 'ngSanitize'])

// inject socket.io into angular
.factory("socket", function (socketFactory) {
  return socketFactory({ioSocket: socket});
})



// Recipe Card Controller
// This manages each recipe card so that it will always stay up to date.
.controller('RecipeCtrl', function($scope, socket, $state, $location, $sce, $sanitize) {

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


  // format the name of a list
  // shrink down the text size when the name is too long
  $scope.format_name = function(n) {
    if (window.innerWidth > 200 + 10 * n.length) {
      return n;
    } else {
      return $sce.trustAsHtml("<span style='font-size: 75%;'>"+$sanitize(n)+"</span>")
    }
  }


  ////
  // Intializers
  ////

})


// Item Info Controller
// Fetch all info about an item so it can be displayed on the
// more info screen for that item
.controller('ItemInfoCtrl', function($scope, socket, $stateParams, $state, AllItems) {
  AllItems.by_id($scope, $stateParams.id, function(val){
    $scope.item = val
  })

  $scope.go_back_to_bag = function() {
    $state.go("tab.bag")
  }
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












.controller('PicksCtrl', function($scope, Chats, $ionicModal) {
  // With the new view caching in Ionic, Controllers are only called
  // when they are recreated or on app start, instead of every page change.
  // To listen for when this page is active (for example, to refresh data),
  // listen for the $ionicView.enter event:
  //
  //$scope.$on('$ionicView.enter', function(e) {
  //});
  //
  
  ////
  // Choose to add a new foodstuff or a recipe
  ////
  $ionicModal.fromTemplateUrl('templates/modal-foodstuff-or-recipe.html', {
    scope: $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    $scope.foodstuff_or_recipe_modal = modal;
  })

  // open the modal to choose between adding a foodstuff or recipe
  $scope.open_foodstuff_or_recipe_modal = function() {
    $scope.foodstuff_or_recipe_modal.show()
  }

  // close the foodstuff vs recipe modal
  $scope.close_foodstuff_or_recipe_modal = function() {
    $scope.foodstuff_or_recipe_modal.hide()
  }


  ////
  // Add a new foodstuff
  ////
  $ionicModal.fromTemplateUrl('templates/modal-add-foodstuff.html', {
    scope : $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    $scope.foodstuff_modal = modal;
  });

  // user wantes to add a new foodstuff
  // open up a new modal to do that in
  $scope.open_add_foodstuff_modal = function() {
    $scope.close_foodstuff_or_recipe_modal()
    $scope.foodstuff_modal.show();
  };

  // close the add foodstuffs modal
  $scope.close_add_foodstuff_modal = function() {
    $scope.foodstuff_modal.hide();
  };


  ////
  // Add a new recipe
  ////
  $ionicModal.fromTemplateUrl('templates/modal-add-recipe.html', {
    scope : $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    $scope.recipe_modal = modal;
  });

  // user wantes to add a new foodstuff
  // open up a new modal to do that in
  $scope.open_add_recipe_modal = function() {
    $scope.close_foodstuff_or_recipe_modal()
    $scope.recipe_modal.show();
  };

  // close the add foodstuffs modal
  $scope.close_add_recipe_modal = function() {
    $scope.recipe_modal.hide();
  };



  ////
  // Initialization
  ////
  //
  //

  $scope.$on('$destroy', function() {
    $scope.foodstuff_or_recipe_modal.remove();
    $scope.foodstuff_modal.remove();
  });

  // TODO old stuff
  $scope.picks = Chats.all();
  $scope.remove = function(chat) {
    Chats.remove(chat);
  };
})




// controller for managing the creation of new foodstuffs
.controller('NewFoodstuffCtrl', function($scope, socket) {

  // create a new foodstuff
  $scope.create_foodstuff = function(name, price, desc) {
    foodstuff = {
      name: name,
      price: price,
      desc: desc,
      tags: []
    }
    socket.emit("foodstuff:create", {foodstuff: foodstuff})
  }


  // we got a callback!
  socket.on("foodstuff:create:callback", function(evt) {
    $scope.confirmed = evt.data
  })

  ////
  // Initialization
  ////
  $scope.init = function() {
    $scope.confirmed = null
  }
  $scope.init()

})




// controller for managing the creation of new foodstuffs
.controller('NewRecipeCtrl', function($scope, socket, $ionicModal, AllItems, searchItem) {


  // new item modal of adding items to the recipe
  $ionicModal.fromTemplateUrl('templates/modal-add-to-bag.html', {
    scope: $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    $scope.item_modal = modal;
  });

  // create a new foodstuff
  $scope.create_recipe = function(name, price, desc) {
    recipe = {
      name: "fake_recipe",//name,
      desc: "our desc",//desc,
      tags: []
    }
    console.log(recipe)
    // socket.emit("list:create", {list: recipe})
  }

  // we got a callback!
  socket.on("list:create:callback", function(evt) {
    $scope.confirmed = evt.data
  })

  // add a new item to the new recipe
  $scope.open_add_item_modal = function() {
    $scope.item_modal.show();

    // get all items and display in the search
    AllItems.all($scope, function(content) {
      $scope.add_items = content
    })
  }

  // add the item to the recipe
  // I know, misleading method name
  $scope.add_item_to_bag = function(item) {
    $scope.recipe_contents.push(item)

    // close modal
    $scope.close_add_modal()
  }

  // close the add item modal
  $scope.close_add_modal = function() {
    $scope.item_modal.hide();
  }

  // open search on the add new items modal
  $scope.open_search = function() {
    searchItem($scope.add_items, function(filtered_items) {
      $scope.add_items = filtered_items
    }).open()
  }

  // cleanup the modal when we're done with it
  $scope.$on('$destroy', function() {
    $scope.item_modal.remove();
  });


  ////
  // Initialization
  ////
  $scope.init = function() {
    $scope.confirmed = null
    $scope.recipe_contents = []
  }
  $scope.init()

})







.controller('ChatDetailCtrl', function($scope, $stateParams, Chats) {
  $scope.chat = Chats.get($stateParams.chatId);
})

.controller('AccountCtrl', function($scope) {
  $scope.settings = {
    enableFriends: true
  };
});
