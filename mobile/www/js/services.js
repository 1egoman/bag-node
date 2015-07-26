angular.module('starter.services', [])


// get all foodstuffs and recipes
.factory("AllItems", function(socket) {
  root = {}
  root.id = {}


  root.by_id = function(sc, id, cb) {
    socket.emit('foodstuff:show', {foodstuff: id})
    socket.emit('list:show', {list: id})
    sc.id_calls = 0

    responseFoodstuff = function(evt) {
      root.id[id] = evt.data || root.id[id]
      sc.id_calls++
      socket.removeListener('foodstuff:show:callback')
    }
    responseList = function(evt) {
      root.id[id] = evt.data || root.id[id]
      sc.id_calls++
      socket.removeListener('list:show:callback')
    }

    sc.$watch('id_calls', function() {
      sc.id_calls == 2 && cb(root.id[id])
    });

    socket.on('foodstuff:show:callback', responseFoodstuff)
    socket.on('list:show:callback', responseList)
  }

  return root


  // root.all = function() {
  //   socket.emit('foodstuff:index')
  //   socket.emit('list:index')
  //
  //   responseFoodstuff = function(evt) {
  //     $scope.item = evt.data || $scope.item
  //     socket.removeListener('foodstuff:index:callback')
  //   }
  //   responseList = function(evt) {
  //     $scope.item = evt.data || $scope.item
  //     socket.removeListener('list:index:callback')
  //   }
  //
  //   socket.on('foodstuff:index:callback', responseFoodstuff)
  //   socket.on('list:index:callback', responseList)
  // }

})



.factory('Chats', function() {
  // Might use a resource here that returns a JSON array

  // Some fake testing data
  var chats = [{
    id: 0,
    name: 'Ben Sparrow',
    lastText: 'You on your way?',
    face: 'https://pbs.twimg.com/profile_images/514549811765211136/9SgAuHeY.png'
  }, {
    id: 1,
    name: 'Max Lynx',
    lastText: 'Hey, it\'s me',
    face: 'https://avatars3.githubusercontent.com/u/11214?v=3&s=460'
  }, {
    id: 2,
    name: 'Adam Bradleyson',
    lastText: 'I should buy a boat',
    face: 'https://pbs.twimg.com/profile_images/479090794058379264/84TKj_qa.jpeg'
  }, {
    id: 3,
    name: 'Perry Governor',
    lastText: 'Look at my mukluks!',
    face: 'https://pbs.twimg.com/profile_images/598205061232103424/3j5HUXMY.png'
  }, {
    id: 4,
    name: 'Mike Harrington',
    lastText: 'This is wicked good ice cream.',
    face: 'https://pbs.twimg.com/profile_images/578237281384841216/R3ae1n61.png'
  }];

  return {
    all: function() {
      return chats;
    },
    remove: function(chat) {
      chats.splice(chats.indexOf(chat), 1);
    },
    get: function(chatId) {
      for (var i = 0; i < chats.length; i++) {
        if (chats[i].id === parseInt(chatId)) {
          return chats[i];
        }
      }
      return null;
    }
  };
});
