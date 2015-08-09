angular.module('starter.controllers.item_info', [])

// Item Info Controller
// Fetch all info about an item so it can be displayed on the
// more info screen for that item
.controller('ItemInfoCtrl', function($scope, socket, $stateParams, $state, AllItems, $ionicHistory, $ionicPopup, user, $ionicLoading) {
  AllItems.by_id($scope, $stateParams.id, function(val){
    $scope.item = val
  })

  $scope.go_back_to_bag = function() {
    $state.go("tab.bag")
  }

  $scope.get_item_or_recipe = function() {
    return $ionicHistory.currentView().stateName.indexOf("recipe") === -1 ?
      "iteminfo" :
      "recipeinfo"
  }


  // get all contents, both sub-recipes and foodstuffs
  $scope.get_all_content = function(bag) {
    if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else return []
  };



  // calculate total price for a whole recipe
  // this takes into account any sub-recipes
  // through recursion. Anything checked off won't be taken into account.
  $scope.calculate_total = function(bag) {
    var total = 0;
    $scope.get_all_content(bag).forEach(function(item) {
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


  // "like" an item
  $scope.fav_item = function(item) {
    socket.emit("user:fav", {item: item._id})
    $scope.favs.push(item._id)

    // give the user a little "notification" about it
    $ionicLoading.show({ template: 'Favorited "'+item.name+'"!', noBackdrop: true, duration: 2000 })
  }

  // un-"like" an item
  $scope.un_fav_item = function(item) {
    socket.emit("user:un_fav", {item: item._id})
    $scope.favs = _.without($scope.favs, item._id)

    // give the user a little "notification" about it
    $ionicLoading.show({ template: 'Un-Favorited "'+item.name+'"!', noBackdrop: true, duration: 2000 })
  }

  // is this a favorite item?
  $scope.is_fav = function() {
    if ($scope.favs && $scope.item) {
      return $scope.favs.indexOf($scope.item._id) !== -1
    } else return false
  }


  // are we a favorite?
  user.then(function(data) {
    $scope.favs = data.favs
  });

})
