
socket = io('http://192.168.1.14:8000/55a84d00e4b06e29cb4eb960', {query: "token=my_token"});
// # socket.emit 'foodstuff:index', list: "55a84255eb8799c52c643830"
//
// # get initial event info from backend
// # socket.emit 'foodstuff:index'
// # socket.on 'foodstuff:index:callback', (event) =>
// #   @push event.data
// #
// # socket.on 'foodstuff:create:callback', (event) =>
// #   @push event.data
// #
// # socket.on 'foodstuff:update:callback', (event) =>
// #   @push event.data
// #
// # socket.on 'foodstuff:delete:callback', (event) =>
// #   @push event.data

// get rid of some of the angular crud
// this is needed when doing client <-> server stuff
strip_$$ = function(a) {
  return angular.fromJson(angular.toJson(a));
};

angular.module('starter.controllers', ['btford.socket-io'])

// inject socket.io into angular
.factory("socket", function (socketFactory) {
  return socketFactory({ioSocket: socket});
})

// Bags Controller
// This manages bags, which can contain recipes or foodstuffs
.controller('BagsCtrl', function($scope, socket) {

  // get all bags
  socket.emit('list:index')
  socket.on('list:index:callback', function(evt){
    console.log(2, evt)
    $scope.bags = evt.data
  });

  // calculate total price for a whole bag
  // this takes into account any sub-recipes
  // through recursion.
  $scope.calculate_total = function(bag) {
    var total = 0;
    bag.contents.forEach(function(item) {
      if (item.contents) {
        // this recipe has items of its own
        total += $scope.calculate_total(item);
      } else if (item.checked !== true) {
        // do total
        total += item.price
      }
    });
    return total;
  };


  // check an item on a bag
  // basically, when an item is checked it doesn't add to any totals
  // because the user is presumed to have bought it already.
  $scope.check_item_on_bag = function(bag, item) {
    console.log("ORIG")
    socket.emit('list:update', {
      list: strip_$$(bag)
    });
  };
  socket.on('list:update:callback', function(evt) {
    // console.log(1, evt.all)
    socket.emit('list:index')
  });


  // get all contents, both sub-lists and foodstuffs
  $scope.get_all_content = function(bag) {
    return bag.contents.concat(bag.contentsList || []);
  };


})

.controller('ChatsCtrl', function($scope, Chats) {
  // With the new view caching in Ionic, Controllers are only called
  // when they are recreated or on app start, instead of every page change.
  // To listen for when this page is active (for example, to refresh data),
  // listen for the $ionicView.enter event:
  //
  //$scope.$on('$ionicView.enter', function(e) {
  //});

  $scope.chats = Chats.all();
  $scope.remove = function(chat) {
    Chats.remove(chat);
  };
})

.controller('ChatDetailCtrl', function($scope, $stateParams, Chats) {
  $scope.chat = Chats.get($stateParams.chatId);
})

.controller('AccountCtrl', function($scope) {
  $scope.settings = {
    enableFriends: true
  };
});
