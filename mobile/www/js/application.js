angular.module('starter', ['ionic', 'jett.ionic.filter.bar', 'ngTagsInput', 'starter.controllers', 'starter.services', 'starter.directives']).run(function($ionicPlatform, $ionicConfig, $rootScope, auth) {
  $ionicPlatform.ready(function() {
    if (window.cordova && window.cordova.plugins && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      cordova.plugins.Keyboard.disableScroll(true);
    }
    if (window.StatusBar) {
      return StatusBar.styleLightContent();
    }
  });
  $ionicConfig.tabs.position('bottom');
  $ionicConfig.tabs.style('standard');
  return $rootScope.hideTabs = !auth.success;
}).config(function($stateProvider, $urlRouterProvider, authProvider) {
  $stateProvider.state('tab', {
    url: '/tab',
    abstract: true,
    templateUrl: 'templates/tabs.html'
  }).state('tab.howtouse', {
    url: '/howtouse',
    views: {
      'view-auth': {
        templateUrl: 'templates/auth/howtouse.html',
        controller: 'onboardCtrl'
      }
    }
  });
  if (authProvider.getSuccess()) {
    $stateProvider.state('tab.bag', {
      url: '/bag',
      views: {
        'tab-bag': {
          templateUrl: 'templates/tab-bag.html',
          controller: 'BagsCtrl'
        }
      }
    }).state('tab.select', {
      url: '/select_sort_method',
      views: {
        'tab-bag': {
          templateUrl: 'templates/tab-select.html',
          controller: 'BagsCtrl'
        }
      }
    }).state('tab.iteminfo', {
      url: '/iteminfo/:id',
      views: {
        'tab-bag': {
          templateUrl: 'templates/item-info.html',
          controller: 'ItemInfoCtrl'
        }
      }
    }).state('tab.recipes', {
      url: '/recipes',
      views: {
        'tab-recipes': {
          templateUrl: 'templates/tab-recipes.html',
          controller: 'RecipesCtrl'
        }
      }
    }).state('tab.recipeinfo', {
      url: '/recipeinfo/:id',
      views: {
        'tab-recipes': {
          templateUrl: 'templates/item-info.html',
          controller: 'ItemInfoCtrl'
        }
      }
    }).state('tab.account', {
      url: '/account',
      views: {
        'tab-account': {
          templateUrl: 'templates/tab-account.html',
          controller: 'AccountCtrl'
        }
      }
    });
    return $urlRouterProvider.otherwise('/tab/bag');
  } else {
    $stateProvider.state('tab.onboard', {
      url: '/onboarding/:step',
      views: {
        'view-auth': {
          templateUrl: 'templates/auth/onboard.html',
          controller: 'onboardCtrl'
        }
      }
    }).state('tab.login', {
      url: '/login',
      views: {
        'view-auth': {
          templateUrl: 'templates/auth/login.html',
          controller: 'authCtrl'
        }
      }
    });
    return $urlRouterProvider.otherwise('/tab/login');
  }
}).filter('titlecase', function() {
  return function(input) {
    var smallWords;
    input = input || '';
    smallWords = /^(a|an|and|as|at|but|by|en|for|if|in|nor|of|on|or|per|the|to|vs?\.?|via)$/i;
    return input.replace(/[A-Za-z0-9\u00C0-\u00FF]+[^\s-]*/g, function(match, index, title) {
      if (index > 0 && index + match.length !== title.length && match.search(smallWords) > -1 && title.charAt(index - 2) !== ':' && (title.charAt(index + match.length) !== '-' || title.charAt(index - 1) === '-') && title.charAt(index - 1).search(/[^\s-]/) < 0) {
        return match.toLowerCase();
      }
      if (match.substr(1).search(/[A-Z]|\../) > -1) {
        return match;
      }
      return match.charAt(0).toUpperCase() + match.substr(1);
    });
  };
});

var auth_module, ref, socket, user_id, user_token;

window.host = "http://10.0.0.7:8000";

auth_module = angular.module('starter.authorization', []);

if (sessionStorage.user) {
  ref = JSON.parse(sessionStorage.user);
  user_id = ref.id;
  user_token = ref.token;
  socket = io(window.host + "/" + user_id, {
    query: "token=" + user_token
  });
  socket.on("connection", function() {
    return console.log(67890);
  });
  (function(auth_module) {
    auth_module;
    return auth_module.provider('auth', function() {
      return {
        getSuccess: function() {
          return true;
        },
        $get: function() {
          return {
            success: true,
            user_id: sessionStorage.user.id,
            user_token: sessionStorage.user.token
          };
        }
      };
    }).factory('socket', function(socketFactory) {
      return socketFactory({
        ioSocket: socket
      });
    }).factory('user', function(userFactory) {
      return userFactory(user_id);
    });
  })(auth_module);
} else {
  auth_module.provider('auth', function() {
    return {
      getSuccess: function() {
        return false;
      },
      $get: function() {
        return {
          success: false
        };
      }
    };
  }).factory('socket', function(socketFactory) {
    return socketFactory({
      ioSocket: io(window.host + "/handshake")
    });
  }).factory('user', function() {
    return {
      then: function() {}
    };
  });
}

window.strip_$$ = function(a) {
  return angular.fromJson(angular.toJson(a));
};

angular.module('starter.controllers', ['btford.socket-io', 'ngSanitize', 'starter.authorization', 'starter.controllers.account', 'starter.controllers.onboarding', 'starter.controllers.tab_bag', 'starter.controllers.tab_recipe', 'starter.controllers.item_info', 'starter.controllers.new_foodstuff', 'starter.controllers.new_recipe', 'starter.controllers.recipe_card', 'starter.controllers.login']).controller('RecipeListCtrl', function($scope, socket, $ionicSlideBoxDelegate) {
  socket.emit('list:index');
  socket.on('list:index:callback', function(evt) {
    $scope.recipes = evt.data;
    $ionicSlideBoxDelegate.update();
  });
});

angular.module('starter.directives', []).directive('recipeCard', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/recipe-card.html',
    require: '^recipe',
    scope: {
      recipe: '=',
      change: '=',
      sortOpts: '=',
      deleteItem: '&',
      moreInfo: '&'
    }
  };
}).directive('checkableItem', function() {
  return {
    restrict: 'E',
    templateUrl: '/templates/checkable-item.html',
    require: '^item',
    scope: {
      item: '=',
      change: '=',
      sortOpts: '=',
      deleteItem: '&',
      moreInfo: '&'
    }
  };
});

angular.module('starter.services', []).factory('AllItems', function(socket) {
  var root;
  root = {};
  root.id = {};
  root.by_id = function(sc, id, cb) {
    var responseFoodstuff, responseList;
    socket.emit('foodstuff:show', {
      foodstuff: id
    });
    socket.emit('list:show', {
      list: id
    });
    sc.id_calls = 0;
    responseFoodstuff = function(evt) {
      root.id[id] = evt.data || root.id[id];
      sc.id_calls++;
      return socket.removeListener('foodstuff:show:callback');
    };
    responseList = function(evt) {
      root.id[id] = evt.data || root.id[id];
      sc.id_calls++;
      return socket.removeListener('list:show:callback');
    };
    sc.$watch('id_calls', function() {
      return sc.id_calls === 2 && cb(root.id[id]);
    });
    socket.on('foodstuff:show:callback', responseFoodstuff);
    return socket.on('list:show:callback', responseList);
  };
  root.all = function(sc, cb) {
    var responseFoodstuff, responseList;
    root.all_resp = [];
    socket.emit('foodstuff:index', {
      limit: sc.amount_in_page,
      start: sc.start_index || 0
    });
    socket.emit('list:index', {
      limit: sc.amount_in_page,
      start: sc.start_index || 0
    });
    sc.all_calls = 0;
    responseFoodstuff = function(evt) {
      root.all_resp = evt.data.concat(root.all_resp || []);
      sc.all_calls++;
      return socket.removeListener('foodstuff:index:callback');
    };
    responseList = function(evt) {
      root.all_resp = evt.data.concat(root.all_resp || []);
      sc.all_calls++;
      return socket.removeListener('list:index:callback');
    };
    sc.$watch('all_calls', function() {
      return sc.all_calls === 2 && cb(root.all_resp);
    });
    socket.on('foodstuff:index:callback', responseFoodstuff);
    return socket.on('list:index:callback', responseList);
  };
  return root;
}).factory('persistant', function() {
  return {
    sort: null,
    sort_opts: {}
  };
}).factory('userFactory', function($q, socket) {
  return function(user_id) {
    var defer;
    defer = $q.defer();
    socket.emit('user:show', {
      user: user_id
    });
    socket.on('user:show:callback', function(evt) {
      defer.resolve(evt.data);
    });
    return defer.promise;
  };
}).factory('searchItem', function($ionicFilterBar) {
  return function(all_items, update_cb) {
    var $scope;
    $scope = {};
    $scope.open = function(on_close) {
      return $scope.hide = $ionicFilterBar.show({
        items: all_items,
        update: function(filteredItems) {
          all_items = filteredItems;
          return update_cb && update_cb(all_items);
        },
        cancel: function() {
          return on_close && on_close();
        },
        filterProperties: 'name'
      });
    };
    return $scope;
  };
});

angular.module('starter.controllers.account', []).controller('AccountCtrl', function($scope, user) {
  user.then(function(user) {
    return $scope.username = user.name;
  });
  return $scope.logout = function() {
    delete sessionStorage.user;
    return location.reload();
  };
});

angular.module('starter.controllers.login', []).controller('authCtrl', function($scope, $http, $state, socket) {
  $scope.login = function(user, pass) {
    socket.emit("login", {
      username: user,
      password: pass
    });
    return socket.on("login:callback", function(data) {
      if (data.msg) {
        return console.log(data);
      } else {
        sessionStorage.user = JSON.stringify({
          id: data._id,
          token: data.token
        });
        return setTimeout(function() {
          location.replace('#/tab/bag');
          return location.reload();
        }, 2000);
      }
    });
  };
  return $scope.to_onboarding = function() {
    return $state.go("tab.onboard", {
      step: 'welcome'
    });
  };
});

angular.module('starter.controllers.tab_bag', []).controller('BagsCtrl', function($scope, $ionicModal, $ionicSlideBoxDelegate, socket, $state, $ionicListDelegate, AllItems, $timeout, persistant, $rootScope, searchItem) {
  socket.emit('bag:index');
  socket.on('bag:index:callback', function(evt) {
    $scope.bag = evt.data;
    $ionicSlideBoxDelegate.update();
    return $scope.sorted_bag = $scope.sort_items();
  });
  $scope.calculate_total = function(bag) {
    var total;
    total = 0;
    $scope.get_all_content(bag, true).forEach(function(item) {
      if (item.checked === true) {
        return;
      } else if (item.contents) {
        total += $scope.calculate_total(item) * (parseFloat(item.quantity) || 1);
      } else {
        total += parseFloat(item.price) * (parseFloat(item.quantity) || 1);
      }
    });
    return total;
  };
  $scope.calculate_total_section = function(items) {
    return _(items).map(function(i) {
      return $scope.calculate_total(i) * i.quantity;
    }).reduce((function(m, x) {
      return m + x;
    }), 0);
  };

  /*
   * Create new item
   */
  $ionicModal.fromTemplateUrl('templates/modal-add-to-bag.html', {
    scope: $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    return $scope.modal = modal;
  });
  $scope.open_add_modal = function() {
    return $scope.modal.show();
  };
  $scope.on_load_more_add_items = function(page_size) {
    if ($scope.add_items_done) {
      return;
    }
    return AllItems.all($scope, function(items) {
      $scope.add_items = $scope.add_items.concat(items);
      $scope.start_index += page_size || $scope.amount_in_page;
      if (items.length < $scope.amount_in_page) {
        $scope.add_items_done = true;
      }
      return $scope.$broadcast('scroll.infiniteScrollComplete');
    });
  };
  $scope.open_search = function() {
    var search;
    search = searchItem($scope.add_items, function(filtered_items) {
      return $scope.add_items = filtered_items;
    });
    search.open();
    return $scope.hide_search = search.hide;
  };
  $scope.close_add_modal = function() {
    $scope.modal.hide();
    return $scope.hide_search && $scope.hide_search();
  };
  $scope.$on('$destroy', function() {
    return $scope.modal.remove();
  });
  $scope.add_item_to_bag = function(item) {
    var item_in_bag;
    console.log(1);
    item.quantity = 1;
    item_in_bag = _($scope.get_all_content($scope.bag)).find(function(i) {
      return i._id === item._id;
    });
    if (item_in_bag && item_in_bag.length !== 0) {
      item_in_bag.quantity = (item_in_bag.quantity || 0) + 1;
    } else if (item.contents) {
      item.contents.forEach(function(i) {
        return i.checked = false;
      });
      $scope.bag.contentsLists.push(item);
    } else {
      $scope.bag.contents.push(item);
    }
    $scope.update_bag();
    return $scope.close_add_modal();
  };

  /*
   * View mechanics
   */
  $scope.is_viewing_bag = function() {
    return $scope.active_card === 0;
  };
  $scope.filter_bag_contents = function() {
    $scope.filter_open = true;
    return searchItem($scope.flatten_bag(), function(filtered_items) {
      return $scope.filtered_items = filtered_items;
    }).open(function() {
      $scope.filtered_items = [];
      return $scope.filter_open = false;
    });
  };
  $scope.flatten_bag = function(bag, opts) {
    var total;
    bag = bag || $scope.bag;
    opts = opts || {};
    if (!bag) {
      return;
    }
    total = [];
    (bag.contents || []).concat(bag.contentsLists || []).forEach(function(item) {
      if (item.contents) {
        total = total.concat($scope.flatten_bag(item, opts));
        if (opts.list_names_index === false) {
          total.push(item);
        }
      } else {
        total.push(item);
      }
    });
    return total;
  };
  $scope.get_all_content = function(bag, return_self) {
    if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else {
      if (return_self) {
        return [bag];
      } else {
        return [];
      }
    }
  };
  $scope.get_marked_items = function(bag) {
    var marked;
    marked = $scope.get_all_content(bag).filter(function(b) {
      return b.checked || b.contents && $scope.all_checked(b);
    });
    return marked;
  };
  $scope.all_checked = function(item) {
    return $scope.get_all_content(item).map(function(item) {
      if (item.contents || item.contentsLists) {
        return $scope.all_checked(item);
      } else {
        return item.checked;
      }
    }).indexOf(false) === -1;
  };
  $scope.more_info = function(item) {
    $ionicListDelegate.closeOptionButtons();
    return $state.go('tab.iteminfo', {
      id: item._id
    });
  };

  /*
   * Updating a bag
   */
  $scope.update_bag = function() {
    return socket.emit('bag:update', {
      bag: window.strip_$$($scope.bag)
    });
  };
  socket.on('bag:update:callback', function(evt) {
    $scope.bag = evt.data;
    return $scope.sorted_bag = $scope.sort_items();
  });

  /*
   * Deleting an item in a bag
   */
  $scope.delete_item = function(item) {
    $scope.bag.contents = $scope.bag.contents.filter(function(i) {
      return i._id !== item._id;
    });
    $scope.bag.contentsLists = $scope.bag.contentsLists.filter(function(i) {
      return i._id !== item._id;
    });
    $scope.update_bag();
  };

  /*
   * switching to list mode
   */
  $scope.to_list_mode = function() {
    return $state.go('tab.select');
  };
  $rootScope.$on('$stateChangeSuccess', function(event, toState) {
    if (toState.name === 'tab.bag') {
      $scope.sorted_bag = $scope.sort_items();
      return $scope.sort_opts = persistant.sort_opts;
    }
  });

  /*
   * Sorting types
   */
  $scope.sort_items = function(bag) {
    var items;
    items = $scope.get_all_content(bag || $scope.bag);
    switch (persistant.sort) {
      case 'completion':
        persistant.sort_opts = $scope.sort_opts = {};
        return _.groupBy(items, function(i) {
          if (i.checked || i.contents && $scope.all_checked(i)) {
            return 'Mutated';
          } else {
            return 'In my bag';
          }
        });
      case 'tags':
        persistant.sort_opts = $scope.sort_opts = {
          checks: true
        };
        return _.groupBy(items, function(i) {
          return _.find(i.tags, function(x) {
            return x.indexOf('sort-') !== -1;
          }) || 'No sort';
        });
      case 'tags_list':
        persistant.sort_opts = $scope.sort_opts = {
          checks: true
        };
        return _.groupBy($scope.flatten_bag(), function(i) {
          return _.find(i.tags, function(x) {
            return x.indexOf('sort-') !== -1;
          }) || 'No sort';
        });
      default:
        persistant.sort_opts = $scope.sort_opts = {};
        return {
          'All Items': items
        };
        break;
    }
  };
  $scope.change_sort = function(new_sort_name) {
    persistant.sort = new_sort_name;
    $scope.sort_opts = persistant.sort_opts;
    return $scope.sorted_bag = $scope.sort_items();
  };

  /*
   * Intializers
   */
  $scope.filter_open = false;
  $scope.filtered_items = [];
  $scope.completed_items = [];
  $scope.echo = function() {
    console.log('Called!');
    return 'Called!';
  };
  $scope.sort_type = persistant.sort || 'no';
  $scope.sorted_bag = [];
  $scope.view_title = 'My Bag';
  $scope.sort_opts = persistant.sort_opts || {};
  $scope.add_items = [];
  $scope.start_index = 0;
  $scope.add_items_done = false;
  return $scope.amount_in_page = 25;
});

angular.module('starter.controllers.item_info', []).controller('ItemInfoCtrl', function($scope, socket, $stateParams, $state, AllItems, $ionicHistory, $ionicPopup, user, $ionicLoading) {
  AllItems.by_id($scope, $stateParams.id, function(val) {
    return $scope.item = val;
  });
  $scope.go_back_to_bag = function() {
    return $state.go('tab.bag');
  };
  $scope.get_item_or_recipe = function() {
    if ($ionicHistory.currentView().stateName.indexOf('recipe') === -1) {
      return 'iteminfo';
    } else {
      return 'recipeinfo';
    }
  };
  $scope.get_all_content = function(bag) {
    if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else {
      return [];
    }
  };
  $scope.calculate_total = function(bag) {
    var total;
    total = 0;
    $scope.get_all_content(bag).forEach(function(item) {
      if (item.checked === true) {
        return;
      } else if (item.contents) {
        total += $scope.calculate_total(item) * (parseFloat(item.quantity) || 1);
      } else {
        total += parseFloat(item.price) * (parseFloat(item.quantity) || 1);
      }
    });
    return total;
  };
  $scope.fav_item = function(item) {
    socket.emit('user:fav', {
      item: item._id
    });
    $scope.favs.push(item._id);
    return $ionicLoading.show({
      template: 'Favorited "' + item.name + '"!',
      noBackdrop: true,
      duration: 2000
    });
  };
  $scope.un_fav_item = function(item) {
    socket.emit('user:un_fav', {
      item: item._id
    });
    $scope.favs = _.without($scope.favs, item._id);
    $ionicLoading.show({
      template: 'Un-Favorited "' + item.name + '"!',
      noBackdrop: true,
      duration: 2000
    });
  };
  $scope.is_fav = function() {
    if ($scope.favs && $scope.item) {
      return $scope.favs.indexOf($scope.item._id) !== -1;
    } else {
      return false;
    }
  };
  return user.then(function(data) {
    return $scope.favs = data.favs;
  });
});

angular.module('starter.controllers.new_foodstuff', []).controller('NewFoodstuffCtrl', function($scope, socket, $q) {
  $scope.predefined_tags = function(query) {
    var defer;
    defer = $q.defer();
    socket.emit('tags:index');
    socket.once('tags:index:callback', function(evt) {
      return defer.resolve(evt.data);
    });
    return defer.promise;
  };
  $scope.create_foodstuff = function(name, price, tags, desc) {
    var foodstuff;
    foodstuff = {
      name: name,
      price: price,
      desc: desc,
      tags: (tags || []).map(function(i) {
        return i.text;
      })
    };
    return socket.emit('foodstuff:create', {
      foodstuff: foodstuff
    });
  };
  socket.on('foodstuff:create:callback', function(evt) {
    return $scope.confirmed = evt.data;
  });

  /*
   * Initialization
   */
  $scope.init = function() {
    return $scope.confirmed = null;
  };
  return $scope.init();
});

angular.module('starter.controllers.new_recipe', []).controller('NewRecipeCtrl', function($scope, socket, $ionicModal, AllItems, searchItem, $q) {
  $ionicModal.fromTemplateUrl('templates/modal-add-to-bag.html', {
    scope: $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    return $scope.item_modal = modal;
  });
  $scope.predefined_tags = function(query) {
    var defer;
    defer = $q.defer();
    socket.emit('tags:index');
    socket.once('tags:index:callback', function(evt) {
      return defer.resolve(evt.data);
    });
    return defer.promise;
  };
  $scope.create_recipe = function(name, tags, desc) {
    var r_contents, r_contentsLists, recipe;
    r_contents = [];
    r_contentsLists = [];
    $scope.recipe_contents.forEach(function(i) {
      if (i.contents) {
        r_contentsLists.push(i);
      } else {
        r_contents.push(i);
      }
    });
    $scope.recipe_contents = [];
    recipe = {
      name: name,
      desc: desc,
      tags: (tags || []).map(function(i) {
        return i.text;
      }),
      contents: window.strip_$$(r_contents),
      contentsLists: strip_$$(r_contentsLists)
    };
    return socket.emit('list:create', {
      list: recipe
    });
  };
  socket.on('list:create:callback', function(evt) {
    return $scope.confirmed = evt.data;
  });
  $scope.open_add_item_modal = function() {
    $scope.item_modal.show();
    return AllItems.all($scope, function(content) {
      return $scope.add_items = content;
    });
  };
  $scope.add_item_to_bag = function(item) {
    $scope.recipe_contents.push(item);
    $scope.close_add_modal();
    return $scope.add_search && $scope.add_search.hide();
  };
  $scope.close_add_modal = function() {
    $scope.item_modal.hide();
    return $scope.add_search && $scope.add_search.hide();
  };
  $scope.open_search = function() {
    $scope.add_search = searchItem($scope.add_items, function(filtered_items) {
      return $scope.add_items = filtered_items;
    });
    return $scope.add_search.open();
  };
  $scope.$on('$destroy', function() {
    return $scope.item_modal.remove();
  });

  /*
   * Initialization
   */
  $scope.init = function() {
    $scope.confirmed = null;
    return $scope.recipe_contents = [];
  };
  return $scope.init();
});

angular.module('starter.controllers.onboarding', []).controller('onboardCtrl', function($scope, user, socket, persistant, $state, $stateParams) {
  $scope.Math = Math;
  socket.on("user:create:callback", function(payload) {
    if (payload.status === "bag.success.user.create") {
      return (function(data) {
        sessionStorage.user = JSON.stringify({
          id: data._id,
          token: data.token
        });
        return setTimeout(function() {
          location.replace('#/tab/bag');
          return location.reload();
        }, 2000);
      })(payload.data);
    } else {
      return $scope.error_logs = "Error creating account: \n" + (JSON.stringify(payload, null, 2));
    }
  });
  socket.on("user:unique:callback", function(payload) {
    return $scope.username_clean = payload.status.indexOf("clean") > -1;
  });
  $scope.to_step = function(step) {
    persistant.new_user = $scope.user;
    return $state.go("tab.onboard", {
      step: step
    });
  };
  $scope.create_account = function(user) {
    $scope.creating_user = user;
    return socket.emit("user:create", {
      user: user
    });
  };
  $scope.to_app = function() {
    return setTimeout(function() {
      location.replace('#/tab/bag');
      return location.reload();
    }, 2000);
  };
  $scope.check_user_unique = function(user) {
    return socket.emit("user:unique", {
      user: user
    });
  };
  $scope.username_clean = false;
  $scope.step = $stateParams.step;
  $scope.title = {
    welcome: "Welcome to Bag!",
    userdetails: "Login Details",
    createaccount: "Create my Account!"
  }[$scope.step];
  return $scope.user = persistant.new_user || {};
});

angular.module('starter.controllers.tab_recipe', []).controller('RecipesCtrl', function($scope, $ionicModal, persistant, $state, $ionicPopup) {

  /*
   * Choose to add a new foodstuff or a recipe
   */
  $ionicModal.fromTemplateUrl('templates/modal-foodstuff-or-recipe.html', {
    scope: $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    return $scope.foodstuff_or_recipe_modal = modal;
  });
  $scope.open_foodstuff_or_recipe_modal = function() {
    return $scope.foodstuff_or_recipe_modal.show();
  };
  $scope.close_foodstuff_or_recipe_modal = function() {
    $scope.foodstuff_or_recipe_modal.hide();
  };

  /*
   * Add a new foodstuff
   */
  $ionicModal.fromTemplateUrl('templates/modal-add-foodstuff.html', {
    scope: $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    return $scope.foodstuff_modal = modal;
  });
  $scope.open_add_foodstuff_modal = function() {
    $scope.close_foodstuff_or_recipe_modal();
    return $scope.foodstuff_modal.show();
  };
  $scope.close_add_foodstuff_modal = function() {
    return $scope.foodstuff_modal.hide();
  };

  /*
   * Add a new recipe
   */
  $ionicModal.fromTemplateUrl('templates/modal-add-recipe.html', {
    scope: $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    return $scope.recipe_modal = modal;
  });
  $scope.open_add_recipe_modal = function() {
    $scope.close_foodstuff_or_recipe_modal();
    return $scope.recipe_modal.show();
  };
  $scope.close_add_recipe_modal = function() {
    return $scope.recipe_modal.hide();
  };

  /*
   * Manage recipes that are already created by user
   */
  $scope.more_info = function(item) {
    return $state.go('tab.recipeinfo', {
      id: item._id
    });
  };
  socket.on('list:index:callback', function(evt) {
    return $scope.my_recipes = evt.data;
  });

  /*
   * Initialization
   */
  $scope.sort_opts = {
    checks: false,
    no_quantity: true,
    no_delete: true
  };
  $scope.my_recipes = [];
  socket.emit('list:index', {
    user: 'me'
  });
  return $scope.$on('$destroy', function() {
    $scope.foodstuff_or_recipe_modal.remove();
    return $scope.foodstuff_modal.remove();
  });
});

angular.module('starter.controllers.recipe_card', []).controller('RecipeCtrl', function($scope, socket, $state, $location, $sce, $sanitize) {
  $scope.calculate_total = function(bag) {
    var total;
    total = 0;
    $scope.get_all_content(bag).forEach(function(item) {
      if (item.checked === true) {
        return;
      } else if (item.contents) {
        total += $scope.calculate_total(item) * (parseFloat(item.quantity) || 1);
      } else {
        total += parseFloat(item.price) * (parseFloat(item.quantity) || 1);
      }
    });
    return total;
  };

  /*
   * Updating a recipe
   */
  $scope.check_item_on_recipe = function(recipe, item) {
    return socket.emit('list:update', {
      list: window.strip_$$(recipe)
    });
  };
  socket.on('list:update:callback', function(evt) {
    if (evt.data) {
      return $scope.recipe = evt.data;
    }
  });
  $scope.get_all_content = function(bag) {
    if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else {
      return [];
    }
  };
  return $scope.format_name = function(n) {
    if (window.innerWidth > 200 + 10 * n.length) {
      return n;
    } else {
      return $sce.trustAsHtml('<span style=\'font-size: 75%;\'>' + $sanitize(n) + '</span>');
    }
  };

  /*
   * Intializers
   */
});
