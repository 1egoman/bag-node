angular.module('starter.controllers.new_foodstuff', [])

.controller 'NewFoodstuffCtrl', ($scope, socket, $q) ->

  # tags to search through
  $scope.predefined_tags = (query) ->
    defer = $q.defer()
    socket.emit 'tags:index'
    socket.once 'tags:index:callback', (evt) ->
      defer.resolve evt.data
    defer.promise

  # create a new foodstuff
  $scope.create_foodstuff = (name, price, tags, desc) ->
    foodstuff =
      name: name
      price: price
      desc: desc
      tags: (tags or []).map((i) ->
        i.text
      )
    socket.emit 'foodstuff:create', foodstuff: foodstuff

  # we got a callback!
  socket.on 'foodstuff:create:callback', (evt) ->
    $scope.confirmed = evt.data

  ###
  # Initialization
  ###
  $scope.init = ->
    $scope.confirmed = null

  $scope.init()
