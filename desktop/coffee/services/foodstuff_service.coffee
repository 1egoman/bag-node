angular.module('bag.services.foodstuff', []).factory 'Foodstuff', (SocketFactory) ->
  SocketFactory 'foodstuff', [
    'index'
    'show'
    'create'
    'update'
    'search'
  ]
