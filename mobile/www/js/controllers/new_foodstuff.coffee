angular.module('bag.controllers.new_foodstuff', [])

.controller 'NewFoodstuffCtrl', (
  $scope
  socket
  $q
  getTagsForQuery
  $timeout
) ->

  # tags to search through
  $scope.predefined_tags = getTagsForQuery

  # create a new foodstuff
  $scope.create_foodstuff = (name, price, tags, desc, priv) ->
    foodstuff =
      name: name
      price: price
      desc: desc
      private: priv or false
      tags: (tags or []).map((i) ->
        i.text
      )
    socket.emit 'foodstuff:create', foodstuff: foodstuff

    # pull it in from the server
    $timeout ->
      socket.emit 'item:index', user: 'me'
    , 100

  # we got a callback!
  socket.on 'foodstuff:create:callback', (evt) ->
    $scope.confirmed = evt.data

  ###
  # Initialization
  ###
  $scope.init = ->
    $scope.confirmed = null

  $scope.init()
