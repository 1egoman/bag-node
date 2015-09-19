angular.module('bag.controllers.new_foodstuff', [])

.controller 'NewFoodstuffCtrl', (
  $scope
  $q
  getTagsForQuery
  $timeout
  Foodstuff
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
    Foodstuff.create
      foodstuff: foodstuff
    .then (evt) ->
      if evt.private
        $scope.close_add_foodstuff_modal()
      else
        $scope.confirmed = evt.data

      # make sure the view is refreshed
      $scope.do_refresh()


  ###
  # Initialization
  ###
  $scope.init = ->
    $scope.confirmed = null

  $scope.init()
