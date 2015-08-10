angular.module('starter.controllers.recipe_card', [])

// Recipe Card Controller
// This manages each recipe card so that it will always stay up to date.
.controller('RecipeCtrl', function($scope, socket, $state, $location, $sce, $sanitize) {

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


  ////
  // Updating a recipe
  ////

  // check an item on a recipe
  // basically, when an item is checked it doesn't add to any totals
  // because the user is presumed to have bought it already.
  $scope.check_item_on_recipe = function(recipe, item) {
    socket.emit('list:update', {
      list: window.strip_$$(recipe)
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
