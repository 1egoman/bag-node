angular.module('starter.controllers.checkableitem', [])
  
.controller 'CheckableItemCtrl', (
  $scope,
  stores
) ->

  # listen for all stores
  # once resolved, we'll use this to display the store next to the price
  stores.then (s) -> $scope.stores = s
  $scope.stores = {}
