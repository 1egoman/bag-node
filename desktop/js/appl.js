(function() {
  angular.module("bag.controller.bag_ctrl", []).controller("BagCtrl", function($scope, Bag, socket) {
    return Bag.index().then(function(data) {
      return console.log(data);
    });
  });

}).call(this);

(function() {
  var ref, user_id, user_token;

  window.host = "http://127.0.0.1:7000";

  if (localStorage.user) {
    ref = JSON.parse(localStorage.user);
    user_id = ref.id;
    user_token = ref.token;
    window.socket = io(window.host + "/" + user_id, {
      query: "token=" + user_token
    });
  } else {
    window.socket = io.connect(host);
  }

  socket.on("login:callback", function(data) {
    if (data.err) {
      return alert("couldn't login.");
    } else {
      return localStorage.user = JSON.stringify({
        id: data._id,
        token: data.token
      });
    }
  });

  socket.emit("login", {
    username: "rgausnet",
    password: "bacon"
  });

  window.strip_$$ = function(a) {
    return angular.fromJson(angular.toJson(a));
  };

  angular.module("bag", ["bag.controller.bag_ctrl", 'bag.services.factory', 'bag.services.bag', 'bag.services.recipe', 'bag.services.foodstuff', "ui.router", "btford.socket-io"]).factory("socket", function(socketFactory) {
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

(function() {
  angular.module('bag.services.bag', []).factory('Bag', function(SocketFactory) {
    return SocketFactory('bag', ['index', 'update']);
  });

}).call(this);

(function() {
  angular.module('bag.services.foodstuff', []).factory('Foodstuff', function(SocketFactory) {
    return SocketFactory('foodstuff', ['index', 'show', 'create', 'update', 'search']);
  });

}).call(this);

(function() {
  angular.module('bag.services.recipe', []).factory('List', function(SocketFactory) {
    return SocketFactory('list', ['index', 'show', 'create', 'update', 'search']);
  });

}).call(this);

(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  angular.module('bag.services.factory', []).factory('SocketFactory', function(socket, $q) {
    return function(name, methods) {
      var fn, get_what_to_send, i, j, len, root;
      root = {};
      get_what_to_send = function(evt) {
        var keys;
        keys = Object.keys(evt);
        if (keys.length === 2 && indexOf.call(keys, 'status') >= 0 && indexOf.call(keys, 'data') >= 0) {
          return evt.data;
        } else {
          return evt;
        }
      };
      fn = function(i) {
        return root[i] = function(opts) {
          var defer;
          if (opts == null) {
            opts = null;
          }
          defer = $q.defer();
          socket.emit(name + ':' + i, window.strip_$$(opts));
          socket.on(name + ':' + i + ':callback', function(evt) {
            if (evt.status.indexOf('success') !== -1) {
              return defer.resolve(get_what_to_send(evt));
            } else {
              return defer.reject(get_what_to_send);
            }
          });
          return defer.promise;
        };
      };
      j = 0;
      len = methods.length;
      while (j < len) {
        i = methods[j];
        fn(i);
        j++;
      }
      return root;
    };
  });

}).call(this);
