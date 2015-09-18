(function() {
  angular.module("bag.controller.bag_ctrl", []).controller("BagCtrl", function($scope) {
    return $scope.a = "123";
  });

}).call(this);

(function() {
  var socket;

  window.host = "http://api.getbag.io";

  socket = io.connect(host);

  angular.module("bag", ["bag.controller.bag_ctrl", "ui.router", "btford.socket-io"]).factory("socket", function(socketFactory) {
    return socketFactory({
      ioSocket: socket
    });
  }).config(function($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise('/bag');
    return $stateProvider.state('bag', {
      url: '/bag',
      views: {
        main: {
          templateUrl: 'templates/bag.html'
        }
      }
    });
  });

}).call(this);
