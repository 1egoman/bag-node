
# window.host = "http://api.getbag.io"
window.host = "http://127.0.0.1:7000"
if localStorage.user
  ref = JSON.parse localStorage.user
  user_id = ref.id
  user_token = ref.token

  # get a reference to the logged-in user
  window.socket = io "#{window.host}/#{user_id}", query: "token=#{user_token}"
else
  window.socket = io.connect host

# login a user
socket.on "login:callback", (data) ->
  if data.err
    alert "couldn't login."
  else
    localStorage.user = JSON.stringify
      id: data._id
      token: data.token


# login a user
socket.emit "login",
    username: "rgausnet"
    password: "bacon"



# get rid of some of the angular crud
# this is needed when doing client <-> server stuff
# strip $hashkey
window.strip_$$ = (a) -> angular.fromJson angular.toJson(a)


angular.module "bag", [
  "bag.controller.bag_ctrl"

  'bag.services.factory'
  'bag.services.bag'
  'bag.services.recipe'
  'bag.services.foodstuff'

  "ui.router"
   "btford.socket-io"
]

.factory "socket", (socketFactory) -> socketFactory ioSocket: socket

.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/bag'

  $stateProvider

  .state 'bag',
    url: '/bag',
    views:
      main:
        templateUrl: 'templates/bag.html'


  # .state 'bag',
  #   url: '/bag',
  #   templateUrl: 'templates/bag.html'

