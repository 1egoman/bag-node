# set up the socket.io connection
# user_id = '55a84d00e4b06e29cb4eb960'
# user_token='my_token'
# window.host = "http://192.168.1.13:8000"
# window.host = "http://bagp.herokuapp.com"
window.host = "10.0.0.7:8000"

auth_module = angular.module 'starter.authorization', []
if sessionStorage.user
  # user_id = '55a84d00e4b06e29cb4eb960'
  # user_token='my_token'
  ref = JSON.parse sessionStorage.user
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
        user_id: sessionStorage.user.id
        user_token: sessionStorage.user.token

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


angular.module 'starter.controllers', [
  'btford.socket-io'
  'ngSanitize'

  # authorization stuff
  'starter.authorization'
  'starter.controllers.onboarding'

  # settings
  'starter.controllers.account'
  'starter.controllers.stores_picker'

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
  'starter.controllers.checkableitem'

  # login controller
  'starter.controllers.login'
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
