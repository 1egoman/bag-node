# set up the socket.io conenction
userId = '55a84d00e4b06e29cb4eb960'

# the logged in user id
socket = io('http://192.168.1.13:8000/' + userId, query: 'token=my_token')

# get rid of some of the angular crud
# this is needed when doing client <-> server stuff
# strip $hashkey
window.strip_$$ = (a) -> angular.fromJson angular.toJson(a)


angular.module 'starter.controllers', [
  'btford.socket-io'
  'ngSanitize'

  # local controllers in different files
  'starter.controllers.tab_bag'
  'starter.controllers.tab_recipe'

  # item info pages, both on bags view and recipes view
  'starter.controllers.item_info'

  # create new recipes and foodstuffs
  'starter.controllers.new_foodstuff'
  'starter.controllers.new_recipe'

  # recipe card controller for recipe-card directive
  'starter.controllers.recipe_card'
]


# inject socket.io into angular
.factory 'socket', (socketFactory) -> socketFactory ioSocket: socket

# logged in user properties
# note: returns a promise
.factory 'user', (userFactory) -> userFactory userId



.controller('RecipeListCtrl', ($scope, socket, $ionicSlideBoxDelegate) ->
  # get all recipes
  # this fires once at the load of the controller, but also repeadedly when
  # any function wants th reload the whole view.
  socket.emit 'list:index'
  socket.on 'list:index:callback', (evt) ->
    # console.log("list:index:callback", evt)
    $scope.recipes = evt.data
    # force the slide-box to update and make
    # each "page" > 0px (stupid bugfix)
    $ionicSlideBoxDelegate.update()
    return
  return
).controller 'AccountCtrl', ->
