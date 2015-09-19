angular.module('bag.services.recipe', []).factory 'List', (SocketFactory) ->
  SocketFactory 'list', [
    'index'
    'show'
    'create'
    'update'
    'search'
  ]
