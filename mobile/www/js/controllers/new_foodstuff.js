angular.module('starter.controllers.new_foodstuff', [])

// controller for managing the creation of new foodstuffs
.controller('NewFoodstuffCtrl', function($scope, socket, $q) {

  // tags to search through
  $scope.predefined_tags = function(query) {
    defer = $q.defer()
    socket.emit("tags:index")
    socket.once("tags:index:callback", function(evt) {
      defer.resolve(evt.data)
    })
    return defer.promise
  };

  // create a new foodstuff
  $scope.create_foodstuff = function(name, price, tags, desc) {
    foodstuff = {
      name: name,
      price: price,
      desc: desc,
      tags: (tags || []).map(function(i) { return i.text })
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
