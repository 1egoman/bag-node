
window.host = "http://api.getbag.io"
socket = io.connect host

angular.module "bag", [
  "bag.controller.bag_ctrl"

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

