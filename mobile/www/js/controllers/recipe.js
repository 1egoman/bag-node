
angular.module('starter.controllers.tab_recipe', [])


.controller('RecipesCtrl', function(
  $scope, 
  $ionicModal, 
  persistant, 
  $state, 
  $ionicPopup
) {
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
  // Manage recipes that are already created by user
  ////


  // send user to more infoabout the specified item
  $scope.more_info = function(item) {
    $state.go('tab.recipeinfo', {id: item._id})
  }

  socket.on("list:index:callback", function(evt) {
    $scope.my_recipes = evt.data
  })


  ////
  // Initialization
  ////
  $scope.sort_opts = {checks: false, no_quantity: true, no_delete: true}
  $scope.my_recipes = []
  socket.emit("list:index", {user: "me"})





  $scope.$on('$destroy', function() {
    $scope.foodstuff_or_recipe_modal.remove();
    $scope.foodstuff_modal.remove();
  });
})




