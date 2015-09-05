angular.module('bag.services.bag', []).factory 'Bag', (SocketFactory) ->
  SocketFactory 'bag', [
    'index'
    'update'
  ]
