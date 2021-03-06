# set up the socket.io connection
# user_id = '55a84d00e4b06e29cb4eb960'
# user_token='my_token'
# window.host = "http://192.168.1.13:8000"
# window.host = "http://127.0.0.1:8000"
# window.host = "http://192.168.1.15:8000"
window.host = "http://api.getbag.io"
# window.host = "http://bagd.herokuapp.com"

auth_module = angular.module 'bag.authorization', []
if localStorage.user
  # user_id = '55a84d00e4b06e29cb4eb960'
  # user_token='my_token'
  ref = JSON.parse localStorage.user
  user_id = ref.id
  user_token = ref.token

  # get a reference to the logged-in user
  socket = io "#{window.host}/#{user_id}", query: "token=#{user_token}"

  # inject these details into the controller
  do (auth_module) ->
    auth_module

    # give ourselves a status inndicaton
    auth_module.provider 'auth', ->
      getSuccess: -> true
      $get: ->
        success: true
        user_id: localStorage.user.id
        user_token: localStorage.user.token

    # inject socket.io into angular
    .factory 'socket', (socketFactory) -> socketFactory ioSocket: socket

    # logged in user properties
    # note: returns a promise
    .factory 'user', (userFactory) -> userFactory user_id


else
  # we aren't authorized...
  # lets make sure we shout this as loud as possible
  auth_module.provider 'auth', ->
    getSuccess: -> false
    $get: -> success: false

  # onboarding factories
  .factory 'socket', (socketFactory) ->
    socketFactory ioSocket: io("#{window.host}/handshake")
  .factory 'user', -> then: ->

# get rid of some of the angular crud
# this is needed when doing client <-> server stuff
# strip $hashkey
window.strip_$$ = (a) -> angular.fromJson angular.toJson(a)


angular.module 'bag.controllers', [
  'btford.socket-io'
  'ngSanitize'

  # authorization stuff
  'bag.authorization'
  'bag.controllers.onboarding'

  # settings
  'bag.controllers.account'
  'bag.controllers.stores_picker'

  # local controllers in different files
  'bag.controllers.tab_bag'
  'bag.controllers.tab_recipe'
  'bag.controllers.tab_picks'

  # item info pages, both on bags view and recipes view
  'bag.controllers.item_info'

  # create new recipes and foodstuffs
  'bag.controllers.new_foodstuff'
  'bag.controllers.new_recipe'

  # recipe card controller for recipe-card directive
  'bag.controllers.recipe_card'

  # login controller
  'bag.controllers.login'
]




.controller 'RecipeListCtrl', ($scope, socket, $ionicSlideBoxDelegate) ->
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
