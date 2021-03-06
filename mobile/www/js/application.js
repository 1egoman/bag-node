angular.module('bag', ['ionic', 'jett.ionic.filter.bar', 'ngTagsInput', 'ngCordova', 'bag.controllers', 'bag.services', 'bag.directives']).run(function($ionicPlatform, $ionicConfig, $rootScope, auth) {
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
    }).state('tab.picks', {
      url: '/picks',
      views: {
        'tab-picks': {
          templateUrl: 'templates/tab-picks.html',
          controller: 'PicksCtrl'
        }
      }
    }).state('tab.recipes', {
      url: '/recipes',
      views: {
        'tab-picks': {
          templateUrl: 'templates/tab-recipes.html',
          controller: 'RecipesCtrl'
        }
      }
    }).state('tab.recipeinfo', {
      url: '/recipeinfo/:id',
      views: {
        'tab-picks': {
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
    }).state('tab.stores', {
      url: '/stores',
      views: {
        'tab-account': {
          templateUrl: 'templates/tab-store-picker.html',
          controller: 'StorePickerCtrl'
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

window.host = "http://api.getbag.io";

auth_module = angular.module('bag.authorization', []);

if (localStorage.user) {
  ref = JSON.parse(localStorage.user);
  user_id = ref.id;
  user_token = ref.token;
  socket = io(window.host + "/" + user_id, {
    query: "token=" + user_token
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
            user_id: localStorage.user.id,
            user_token: localStorage.user.token
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

angular.module('bag.controllers', ['btford.socket-io', 'ngSanitize', 'bag.authorization', 'bag.controllers.onboarding', 'bag.controllers.account', 'bag.controllers.stores_picker', 'bag.controllers.tab_bag', 'bag.controllers.tab_recipe', 'bag.controllers.tab_picks', 'bag.controllers.item_info', 'bag.controllers.new_foodstuff', 'bag.controllers.new_recipe', 'bag.controllers.recipe_card', 'bag.controllers.login']).controller('RecipeListCtrl', function($scope, socket, $ionicSlideBoxDelegate) {
  socket.emit('list:index');
  socket.on('list:index:callback', function(evt) {
    $scope.recipes = evt.data;
    $ionicSlideBoxDelegate.update();
  });
});

angular.module('bag.directives', []).directive('recipeCard', function() {
  return {
    restrict: 'E',
    templateUrl: 'templates/recipe-card.html',
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
    templateUrl: 'templates/checkable-item.html',
    require: '^item',
    scope: {
      item: '=',
      change: '=',
      sortOpts: '=',
      deleteItem: '&',
      moreInfo: '&'
    },
    controller: function($scope, stores) {
      stores.then(function(s) {
        return $scope.stores = s;
      });
      $scope.stores = {};
      $scope.host = window.host;
      return $scope.encodeURI = window.encodeURIComponent;
    }
  };
}).directive("loadingSpinner", function() {
  return {
    restrict: 'E',
    templateUrl: 'templates/spinner.html',
    scope: {
      complete: '='
    },
    controller: function($scope) {
      return $scope.motivationalMessage = _.sample(["Just a little bit longer", "It's worth the wait", "Pardon us", "We're a little slow today"]) + '.';
    }
  };
});

var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('bag.services', ['bag.services.factory', 'bag.services.bag', 'bag.services.recipe', 'bag.services.foodstuff']).factory('AllItems', function(socket, List, Foodstuff) {
  var root;
  root = {};
  root.id = {};
  root.by_id = function(sc, id, cb) {
    sc.id_calls = 0;
    List.show({
      list: id
    }).then(function(evt) {
      root.id[id] = evt || root.id[id];
      return sc.id_calls++;
    });
    Foodstuff.show({
      foodstuff: id
    }).then(function(evt) {
      root.id[id] = evt || root.id[id];
      return sc.id_calls++;
    });
    return sc.$watch('id_calls', function() {
      return sc.id_calls === 2 && cb(root.id[id]);
    });
  };
  root.all = function(sc, cb) {
    root.all_resp = [];
    List.index({
      limit: sc.amount_in_page,
      start: sc.start_index || 0
    }).then(function(evt) {
      root.all_resp = evt.concat(root.all_resp || []);
      return sc.all_calls++;
    });
    Foodstuff.index({
      limit: sc.amount_in_page,
      start: sc.start_index || 0
    }).then(function(evt) {
      root.all_resp = evt.concat(root.all_resp || []);
      return sc.all_calls++;
    });
    sc.all_calls = 0;
    return sc.$watch('all_calls', function() {
      return sc.all_calls === 2 && cb(root.all_resp);
    });
  };
  root.search = function(sc, search_str, cb) {
    sc.id_calls = 0;
    List.search({
      list: search_str
    }).then(function(evt) {
      root.id[id] = evt || root.id[id];
      return sc.id_calls++;
    });
    Foodstuff.search({
      foodstuff: search_str
    }).then(function(evt) {
      root.id[id] = evt || root.id[id];
      return sc.id_calls++;
    });
    return sc.$watch('id_calls', function() {
      return sc.id_calls === 2 && cb(root.id[id]);
    });
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
      window.user = evt.data;
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
}).factory('calculateTotal', function(pickPrice, user) {
  var calculate_total, get_all_content;
  get_all_content = function(bag, return_self) {
    if (bag.length) {
      return bag;
    } else if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else {
      if (return_self) {
        return [bag];
      } else {
        return [];
      }
    }
  };
  calculate_total = function(bag) {
    var total;
    total = 0;
    get_all_content(bag, true).forEach(function(item) {
      if (!item) {
        return 0;
      }
      if (item.checked === true) {
        return 0;
      } else if (item.contents) {
        return total += calculate_total(item) * (parseFloat(item.quantity) || 1);
      } else {
        return total += pickPrice(item) * (parseFloat(item.quantity) || 1);
      }
    });
    return total;
  };
  return calculate_total;
}).factory('pickPrice', function() {
  return function(item, user) {
    var pickable_stores, possible_stores, price, ref, store;
    if (user == null) {
      user = window.user;
    }
    if (!user) {
      return;
    }
    if (item.store && item.stores && item.stores[item.store] && (ref = item.store, indexOf.call(user.stores, ref) >= 0)) {
      return item.stores[item.store].price;
    } else if (item.stores && user && user.stores.length) {
      possible_stores = _.mapObject(item.stores, function(v, k) {
        return v.price;
      });
      pickable_stores = _.mapObject(possible_stores, function(v, ea) {
        return indexOf.call(user.stores, ea) >= 0;
      });
      pickable_stores = _.keys(pickable_stores);
      price = _.min(pickable_stores.map(function(s) {
        return item.stores[s].price;
      })) || _.min(_.mapObject(item.stores, function(v, k) {
        return v.price;
      }));
      store = _.invert(possible_stores)[price];
      if (store) {
        item.store = store;
      }
      return price;
    } else {
      item.store = null;
      return item.price || 0;
    }
  };
}).factory('stores', function(socket, $q) {
  var defer;
  defer = $q.defer();
  socket.emit("store:index");
  socket.on("store:index:callback", function(evt) {
    var i, item, len, ref, stores;
    stores = {};
    ref = evt.data;
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      stores[item._id] = item;
    }
    defer.resolve(stores);
  });
  return defer.promise;
}).factory("storePicker", function($ionicModal, $q, stores, user, $state, $timeout, $cordovaDialogs) {
  return function($scope, item) {
    var initial_p, p;
    initial_p = $q.defer();
    p = $q.defer();
    $scope.store_picker_modal = null;
    $ionicModal.fromTemplateUrl('templates/model-pick-store.html', {
      scope: $scope,
      animation: 'slide-in-up'
    }).then(function(m) {
      $scope.store_picker_modal = m;
      return stores.then(function(s) {
        return user.then(function(u) {
          $scope.store_picker.stores = _.compact(_.map(u.stores, function(v) {
            var obj;
            if ($scope.item.stores && $scope.item.stores[v]) {
              obj = s[v];
              obj.price_for_item = $scope.item.stores[v].price;
              return obj;
            }
          }));
          return initial_p.resolve({
            choose: function() {
              $scope.store_picker_modal.show();
              return p.promise;
            },
            close: function() {
              return $scope.store_picker_modal.hide();
            }
          });
        });
      });
    });
    $scope.store_picker = {
      user: null,
      pick_store: function(item) {
        p.resolve(item);
        return $scope.store_picker_modal.hide();
      },
      dismiss: function() {
        p.resolve(null);
        return $scope.store_picker_modal.hide();
      },
      to_stores_picker: function() {
        this.dismiss();
        $state.go("tab.account");
        return $timeout(function() {
          return $state.go("tab.stores");
        }, 100);
      },
      to_custom_price: function() {
        return this.do_custom_price = true;
      },
      custom_price: function(price) {
        var base;
        (base = $scope.item).stores || (base.stores = {});
        $scope.item.stores["custom"] = {
          price: parseFloat(price)
        };
        return this.pick_store({
          _id: "custom"
        });
      },
      to_suggest_store: function() {
        return this.do_suggest_store = true;
      },
      suggest_store: function(store) {
        console.log(store);
        socket.emit("store:suggest", store);
        return socket.on("store:suggest:callback", function(evt) {
          console.log(evt);
          if (evt.resolves_to) {
            return this.pick_store(evt.resolves_to);
          } else {
            $cordovaDialogs.alert("We'll take a look at this and add it soon.", "Thanks", "OK");
            return $scope.store_picker_modal.hide();
          }
        });
      }
    };
    user.then(function(u) {
      return $scope.store_picker.user = u;
    });
    $scope.$on('$destroy', function() {
      return $scope.store_picker_modal.remove();
    });
    return initial_p.promise;
  };
}).factory("getTagsForQuery", function(socket, $q) {
  return function(query) {
    var defer;
    defer = $q.defer();
    socket.emit('tag:show', {
      tag: query
    });
    socket.once('tag:show:callback', function(evt) {
      return defer.resolve(evt.data);
    });
    return defer.promise;
  };
});

angular.module('bag.controllers.account', []).controller('AccountCtrl', function($scope, user, $state, $cordovaDialogs) {
  user.then(function(user) {
    return $scope.username = user.name;
  });
  socket.on('user:show:callback', function(evt) {
    var old_plan;
    user = evt.data;
    $scope.user_plan || ($scope.user_plan = "");
    old_plan = $scope.user_plan.slice(0);
    $scope.user_plan = (function(plan) {
      switch (plan) {
        case 0:
          return "Bag Free";
        case 1:
          return "Bag Pro";
        case 2:
          return "Bag Executive";
        default:
          return "Unknown";
      }
    })(user.plan);
    if (old_plan.length && old_plan !== $scope.user_plan) {
      return $cordovaDialogs.alert("FYI, because of your new plan, some features may not be available until you restart the application.", "Reload App", 'Ok');
    }
  });
  $scope.refresh_user = function() {
    return socket.emit('user:show', {
      user: user_id
    });
  };
  $scope.refresh_user();
  $scope.logout = function() {
    delete localStorage.user;
    return location.reload();
  };
  return $scope.to_stores_chooser = function() {
    return $state.go("tab.stores");
  };
});

angular.module('bag.controllers.login', []).controller('authCtrl', function($scope, $http, $state, socket, $ionicLoading, $cordovaDialogs) {
  socket.on("login:callback", function(data) {
    if (data.err) {
      return $cordovaDialogs.alert("Those login credentials don't match what we have on file. Give it another try?", "Incorrect Credentials", "OK");
    } else {
      localStorage.user = JSON.stringify({
        id: data._id,
        token: data.token
      });
      $ionicLoading.show({
        template: 'Loading<br/><br/><ion-spinner></ion-spinner>'
      });
      return setTimeout(function() {
        location.replace('#/tab/bag');
        $ionicLoading.hide();
        return location.reload();
      }, 2000);
    }
  });
  $scope.login = function(user, pass) {
    return socket.emit("login", {
      username: user,
      password: pass
    });
  };
  return $scope.to_onboarding = function() {
    return $state.go("tab.onboard", {
      step: 'welcome'
    });
  };
});

angular.module('bag.controllers.tab_bag', []).controller('BagsCtrl', function($scope, $ionicModal, socket, $state, $ionicListDelegate, AllItems, $timeout, persistant, $rootScope, searchItem, calculateTotal, pickPrice, stores, $cordovaDialogs, Bag) {
  var load_bag;
  load_bag = function(bag) {
    $scope.bag = bag;
    $scope.sorted_bag = $scope.sort_items();
    return $scope.$broadcast('scroll.refreshComplete');
  };
  Bag.index().then(load_bag);
  $scope.calculate_total = calculateTotal;
  $scope.calculate_total_section = function(items) {
    return _(items).map(function(i) {
      return {
        price: $scope.calculate_total(i),
        ref: i
      };
    }).reduce((function(m, x) {
      return m + x.price * x.ref.quantity;
    }), 0);
  };
  $scope.get_lowest_price = function(item) {
    return calculateTotal(item);
  };
  $scope.do_refresh = function() {
    return Bag.index().then(load_bag);
  };
  stores.then(function(s) {
    return $scope.stores = s;
  });
  $scope.stores = {};

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
  $scope.close_add_modal = function() {
    return $scope.modal.hide();
  };
  $scope.$on('$destroy', function() {
    return $scope.modal.remove();
  });
  $scope.add_item_to_bag = function(item) {
    var item_in_bag;
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
  $scope.on_search_change = function(txt) {
    return socket.emit("item:search", {
      item: txt
    });
  };
  socket.on("item:search:callback", function(payload) {
    if (payload.data) {
      return $scope.add_items = payload.data;
    }
  });

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
    return Bag.update({
      bag: $scope.bag
    }).then(function(data) {
      return $scope.sorted_bag = $scope.sort_items();
    });
  };

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
      case 'tags_store':
        persistant.sort_opts = $scope.sort_opts = {
          checks: true
        };
        return _.groupBy($scope.flatten_bag(), function(i) {
          var tag_sort;
          tag_sort = _.find(i.tags, function(x) {
            return x.indexOf('sort-') !== -1;
          }) || 'No sort';
          if (i.store) {
            return $scope.stores[i.store].name + ": " + tag_sort;
          } else {
            return "No Store: " + tag_sort;
          }
        });
      default:
        persistant.sort_opts = $scope.sort_opts = {};
        return {
          'All Items': items
        };
        break;
    }
  };
  $scope.show_filter_help = function(sort) {
    switch (sort) {
      case 'tags':
        return $cordovaDialogs.alert("Category Filter\nEach item in the bag is sorted by its type. Milk would go under dairy, chicken would go under meats, etc.", "Filter Help", 'Ok');
      case 'tags_store':
        return $cordovaDialogs.alert("Category Filter\nEach item in the bag is sorted by its type. Milk would go under dairy, chicken would go under meats, etc. However, recipes are broken down into their elemental foodstuffs, so you can check off each item as you buy it.", "Filter Help", 'Ok');
      case 'completion':
        return $cordovaDialogs.alert("Checked Filter\nSort items depending on if an item is checked.", "Filter Help", 'Ok');
    }
  };
  $scope.change_sort = function(new_sort_name) {
    persistant.sort = $scope.sort_type = new_sort_name;
    $scope.sort_opts = persistant.sort_opts;
    return $scope.sorted_bag = $scope.sort_items();
  };

  /*
   * Intializers
   */
  $scope.filter_open = false;
  $scope.filtered_items = [];
  $scope.completed_items = [];
  $scope.sort_type = persistant.sort || 'no';
  $scope.sorted_bag = [];
  $scope.view_title = 'My Bag';
  $scope.sort_opts = persistant.sort_opts || {};
  $scope.add_items = [];
  $scope.start_index = 0;
  $scope.add_items_done = false;
  $scope.amount_in_page = 25;
  return $scope.host = window.host;
});

angular.module('bag.controllers.item_info', []).controller('ItemInfoCtrl', function($scope, socket, $stateParams, $state, AllItems, $ionicHistory, $ionicPopup, user, $ionicLoading, calculateTotal, stores, storePicker, Bag, $cordovaDialogs) {
  $scope.get_item_or_recipe = function() {
    if ($ionicHistory.currentView().stateName.indexOf('recipe') === -1) {
      return 'iteminfo';
    } else {
      return 'recipeinfo';
    }
  };
  $scope.click_if_recipe = function() {
    if ($scope.get_item_or_recipe() === 'recipeinfo') {
      return socket.emit("user:click", {
        recipe: $scope.item._id
      });
    }
  };
  $scope.get_store_details = function() {
    var ref, ref1;
    if (((ref = $scope.item) != null ? ref.store : void 0) === "custom") {
      return $scope.store = {
        _id: "custom",
        name: "Custom Price",
        desc: "User-created price",
        image: "https://cdn1.iconfinder.com/data/icons/basic-ui-elements-round/700/06_ellipsis-512.png"
      };
    } else if ((ref1 = $scope.item) != null ? ref1.store : void 0) {
      return stores.then(function(s) {
        return $scope.store = s[$scope.item.store];
      });
    } else {
      return $scope.store = {
        name: "No Store",
        desc: "Please choose a store."
      };
    }
  };
  $ionicLoading.show({
    template: "Loading..."
  });
  user.then(function(usr) {
    socket.emit("bag:index", {
      user: usr._id
    });
    return socket.on("bag:index:callback", function(bag) {
      var to_level;
      $scope.bag = bag.data;
      $ionicLoading.hide();
      to_level = function(haystack) {
        var flattened, j, len, list_contents, needle, results;
        if (haystack == null) {
          haystack = $scope.bag;
        }
        list_contents = (haystack.contentsLists || []).map(function(i) {
          return i.contents;
        });
        flattened = list_contents.concat(haystack.contents).concat(haystack.contentsLists || []);
        results = [];
        for (j = 0, len = flattened.length; j < len; j++) {
          needle = flattened[j];
          if (needle && needle._id === $stateParams.id) {
            $scope.item = needle;
            $scope.get_store_details();
            $scope.click_if_recipe();
            break;
          } else if (needle) {
            results.push(to_level(needle));
          } else {
            results.push(void 0);
          }
        }
        return results;
      };
      to_level();
      if (!$scope.item) {
        return AllItems.by_id($scope, $stateParams.id, function(val) {
          $scope.item = val;
          $scope.get_store_details = function() {};
          return $scope.click_if_recipe();
        });
      }
    });
  });
  $scope.go_back_to_bag = function() {
    return $state.go('tab.bag');
  };
  $scope.set_item_quantity = function(item, quant) {
    item.quantity = quant;
    $scope.find_in_bag(item._id, function(item) {
      return item.quantity = quant;
    });
    return socket.emit('bag:update', {
      bag: window.strip_$$($scope.bag)
    });
  };
  $scope.find_in_bag = function(id, cb) {
    var to_level;
    to_level = function(haystack) {
      var j, len, list_contents, needle, ref, results;
      if (haystack == null) {
        haystack = $scope.bag;
      }
      list_contents = (haystack.contentsLists || []).map(function(i) {
        return i.contents;
      });
      ref = list_contents.concat(haystack.contents);
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        needle = ref[j];
        if (needle && needle._id === id) {
          cb(needle);
          break;
        } else if (needle) {
          results.push(to_level(needle));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };
    return to_level();
  };
  $scope.open_store_chooser = function() {
    return storePicker($scope).then(function(store) {
      return store.choose().then(function(resp) {
        if (resp) {
          $scope.item.store = resp._id;
          $scope.get_store_details();
          $scope.find_in_bag($scope.item._id, function(item) {
            return item.store = resp._id;
          });
          return socket.emit('bag:update', {
            bag: window.strip_$$($scope.bag)
          });
        }
      });
    });
  };
  $scope.get_all_content = function(bag) {
    if (bag && bag.contents) {
      return bag.contents.concat(bag.contentsLists || []);
    } else {
      return [];
    }
  };
  $scope.calculate_total = calculateTotal;
  $scope.fav_item = function(item) {
    socket.emit('user:fav', {
      item: item._id
    });
    $scope.favs.push(item._id);
    return $ionicLoading.show({
      template: 'Favorited "' + item.name + '"!',
      noBackdrop: true,
      duration: 750
    });
  };
  $scope.un_fav_item = function(item) {
    socket.emit('user:un_fav', {
      item: item._id
    });
    $scope.favs = _.without($scope.favs, item._id);
    return $ionicLoading.show({
      template: 'Un-Favorited "' + item.name + '"!',
      noBackdrop: true,
      duration: 750
    });
  };
  $scope.is_fav = function() {
    if ($scope.favs && $scope.item) {
      return $scope.favs.indexOf($scope.item._id) !== -1;
    } else {
      return false;
    }
  };
  user.then(function(data) {
    return $scope.favs = data.favs;
  });
  $scope.item_to_bag = function(item) {
    return Bag.index().then(function(all) {
      var in_bag;
      console.log(all);
      in_bag = (function(bag) {
        if (item.contents) {
          return all.contentsLists.filter(function(c) {
            return c._id.toString() === item._id.toString();
          });
        } else {
          return all.contents.filter(function(c) {
            return c._id.toString() === item._id.toString();
          });
        }
      })(all);
      if (item && in_bag.length) {
        return $cordovaDialogs.alert("Item already in bag", "In Bag", 'OK');
      } else {
        item.quantity = 1;
        if (item.contents) {
          all.contentsLists.push(item);
        } else {
          all.contents.push(item);
        }
        return Bag.update({
          bag: all
        }).then(function() {
          return $state.go("tab.bag");
        });
      }
    });
  };

  /*
   * Initializers
   */
  $scope.store = {};
  $scope.host = window.host;
  return $scope.encodeURI = window.encodeURIComponent;
});

angular.module('bag.controllers.new_foodstuff', []).controller('NewFoodstuffCtrl', function($scope, $q, getTagsForQuery, $timeout, Foodstuff) {
  $scope.predefined_tags = getTagsForQuery;
  $scope.create_foodstuff = function(name, price, tags, desc, priv) {
    var foodstuff;
    foodstuff = {
      name: name,
      price: price,
      desc: desc,
      "private": priv || false,
      tags: (tags || []).map(function(i) {
        return i.text;
      })
    };
    return Foodstuff.create({
      foodstuff: foodstuff
    }).then(function(evt) {
      if (evt["private"]) {
        $scope.close_add_foodstuff_modal();
      } else {
        $scope.confirmed = evt.data;
      }
      return $scope.do_refresh();
    });
  };

  /*
   * Initialization
   */
  $scope.init = function() {
    return $scope.confirmed = null;
  };
  return $scope.init();
});

angular.module('bag.controllers.new_recipe', []).controller('NewRecipeCtrl', function($scope, socket, $ionicModal, AllItems, searchItem, $q, getTagsForQuery, $timeout) {
  $ionicModal.fromTemplateUrl('templates/modal-add-to-bag.html', {
    scope: $scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    return $scope.item_modal = modal;
  });
  $scope.predefined_tags = getTagsForQuery;
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
    socket.emit('list:create', {
      list: recipe
    });
    return $timeout(function() {
      return socket.emit('item:index', {
        user: 'me'
      });
    }, 100);
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

angular.module('bag.controllers.onboarding', []).controller('onboardCtrl', function($scope, user, socket, persistant, $state, $stateParams) {
  socket.on("user:create:callback", function(payload) {
    if (payload.status === "bag.success.user.create") {
      return (function(data) {
        localStorage.user = JSON.stringify({
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

angular.module('bag.controllers.tab_picks', []).controller('PicksCtrl', function($scope, $ionicModal, persistant, $state, $ionicPopup, socket) {
  var load_picks;
  load_picks = function() {
    socket.emit("pick:index");
    return socket.on("pick:index:callback", function(payload) {
      if (payload.data) {
        $scope.picks = _.sortBy(payload.data.picks, function(i) {
          return i.score || 0;
        });
      }
      return $scope.$broadcast('scroll.refreshComplete');
    });
  };
  load_picks();
  $scope.do_refresh = function() {
    return load_picks();
  };
  $scope.to_user_recipes = function() {
    return $state.go("tab.recipes");
  };
  $scope.more_info = function(item) {
    return $state.go("tab.recipeinfo", {
      id: item._id
    });
  };
  $scope.delete_item = function(pick) {
    $scope.picks = _.without($scope.picks, pick);
    return socket.emit("pick:delete", {
      pick: pick._id
    });
  };

  /*
   * Initialization
   */
  return $scope.host = window.host;
});

angular.module('bag.controllers.tab_recipe', []).controller('RecipesCtrl', function($scope, $ionicModal, persistant, $state, $ionicPopup, user) {

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
  socket.on('item:index:callback', function(evt) {
    var i, j, len, ref;
    $scope.my_recipes = evt.data;
    ref = $scope.my_recipes;
    for (j = 0, len = ref.length; j < len; j++) {
      i = ref[j];
      $scope.sort_opts[i._id] = $scope.make_sort_opts(i);
    }
    $scope.$apply();
    return $scope.$broadcast('scroll.refreshComplete');
  });
  $scope.user_more_private = function(user) {
    if (!user) {
      return false;
    } else if (user.plan === 1) {
      return $scope.my_recipes.filter(function(r) {
        return r["private"];
      }).length < 10;
    } else if (user.plan === 2) {
      return true;
    } else {
      return false;
    }
  };
  $scope.make_sort_opts = function(item) {
    if (item["private"]) {
      return {
        checks: false,
        no_quantity: true
      };
    } else {
      return {
        checks: false,
        no_quantity: true,
        no_delete: true
      };
    }
  };
  $scope.delete_item = function(item) {
    socket.emit("foodstuff:destroy", {
      foodstuff: item._id
    });
    return $scope.my_recipes = _.without($scope.my_recipes, item);
  };
  $scope.do_refresh = function() {
    return socket.emit('item:index', {
      user: 'me'
    });
  };

  /*
   * Initialization
   */
  $scope.my_recipes = [];
  $scope.sort_opts = {};
  return user.then(function(u) {
    $scope.user = u;
    socket.emit('item:index', {
      user: 'me'
    });
    return $scope.$on('$destroy', function() {
      $scope.foodstuff_or_recipe_modal.remove();
      return $scope.foodstuff_modal.remove();
    });
  });
});

angular.module('bag.controllers.recipe_card', []).controller('RecipeCtrl', function($scope, socket, $state, $location, $sce, $sanitize, calculateTotal) {
  $scope.calculate_total = calculateTotal;

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

var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('bag.controllers.stores_picker', []).controller('StorePickerCtrl', function($scope, socket, user, $ionicActionSheet) {
  socket.emit("store:index");
  socket.on("store:index:callback", function(payload) {
    $scope.stores = payload.data;
    return $scope.sort_stores(payload.data);
  });
  user.then(function(user) {
    return $scope.user = user;
  });
  $scope.sort_stores = function(stores) {
    $scope.my_stores = _.compact(stores.map(function(s) {
      var ref1;
      return (ref1 = s._id, indexOf.call($scope.user.stores, ref1) >= 0) && s;
    }));
    $scope.other_stores = _.compact(stores.map(function(s) {
      var ref1;
      return (ref1 = s._id, indexOf.call($scope.user.stores, ref1) < 0) && s;
    }));
    return socket.emit("user:updatestores", {
      user: $scope.user._id,
      stores: $scope.user.stores
    });
  };
  $scope.toggle_store_in_user = function(item, user) {
    var ref1;
    if (user == null) {
      user = $scope.user;
    }
    if (ref1 = item._id, indexOf.call(user.stores, ref1) < 0) {
      user.stores.push(item._id);
    } else {
      user.stores = _.without(user.stores, item._id);
    }
    return $scope.sort_stores($scope.stores);
  };
  return $scope.item_details = function(item) {
    var actionsheet_cb, hideSheet, ref1, ref2, ref3;
    actionsheet_cb = function(index) {
      var ref;
      switch (index) {
        case 0:
          $scope.toggle_store_in_user(item);
          break;
        case 1:
          ref = window.open(item.website, '_system', 'location=yes');
      }
      return true;
    };
    if ((ref1 = window.plugins) != null ? ref1.actionsheet : void 0) {
      return window.plugins.actionsheet.show({
        buttonLabels: [(ref2 = item._id, indexOf.call($scope.user.stores, ref2) < 0) && 'Add to My Stores' || 'Remove from My Stores', "Go to store website"],
        title: "Modify store",
        addCancelButtonWithLabel: "Cancel",
        androidEnableCancelButton: true,
        winphoneEnableCancelButton: true
      }, function(index) {
        actionsheet_cb(index - 1);
        return $scope.$apply();
      });
    } else {
      return hideSheet = $ionicActionSheet.show({
        buttons: [
          {
            text: (ref3 = item._id, indexOf.call($scope.user.stores, ref3) < 0) && 'Add to My Stores' || 'Remove from My Stores'
          }, {
            text: 'Go to store website'
          }
        ],
        titleText: 'Modify Store',
        cancelText: 'Cancel',
        cancel: function() {
          return hideSheet();
        },
        buttonClicked: actionsheet_cb
      });
    }
  };
});

angular.module('bag.services.bag', []).factory('Bag', function(SocketFactory) {
  return SocketFactory('bag', ['index', 'update']);
});

angular.module('bag.services.foodstuff', []).factory('Foodstuff', function(SocketFactory) {
  return SocketFactory('foodstuff', ['index', 'show', 'create', 'update', 'search']);
});

angular.module('bag.services.recipe', []).factory('List', function(SocketFactory) {
  return SocketFactory('list', ['index', 'show', 'create', 'update', 'search']);
});

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
