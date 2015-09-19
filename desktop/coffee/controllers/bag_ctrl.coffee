angular.module "bag.controller.bag_ctrl", []

.controller "BagCtrl", ($scope, Bag, socket) ->
  Bag.index().then (data) ->
    console.log data
