// Ionic Starter App

// angular.module is a global place for creating, registering and retrieving Angular modules
// 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
// the 2nd parameter is an array of 'requires'
// 'starter.services' is found in services.js
// 'starter.controllers' is found in controllers.js
angular.module('starter', [
  'ionic',
  // 'ngCordova',
  'jett.ionic.filter.bar',
  'ngTagsInput',

  'starter.controllers',
  'starter.services',
  'starter.directives'
])

.run(function($ionicPlatform, $ionicConfig) {

  // ionic stuff
  $ionicPlatform.ready(function() {
    // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    // for form inputs)
    if (window.cordova && window.cordova.plugins && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      cordova.plugins.Keyboard.disableScroll(true);

    }
    if (window.StatusBar) {
      // org.apache.cordova.statusbar required
      StatusBar.styleLightContent();
    }
  });


  // change the statusbar so it looks a little better
  // $cordovaStatusbar.overlaysWebView(false)
  // $cordovaStatusBar.style(1) //Light
  // $cordovaStatusBar.style(2) //Black, transulcent
  // $cordovaStatusBar.style(3) //Black, opaque
  
  $ionicConfig.tabs.position("bottom"); //Places them at the bottom for all OS
  $ionicConfig.tabs.style("standard"); //Makes them all look the same across all OS
})

.config(function($stateProvider, $urlRouterProvider) {

  // Ionic uses AngularUI Router which uses the concept of states
  // Learn more here: https://github.com/angular-ui/ui-router
  // Set up the various states which the app can be in.
  // Each state's controller can be found in controllers.js
  $stateProvider

  // setup an abstract state for the tabs directive
    .state('tab', {
    url: '/tab',
    abstract: true,
    templateUrl: 'templates/tabs.html'
  })

  // Each tab has its own nav history stack:

  .state('tab.bag', {
    url: '/bag',
    views: {
      'tab-bag': {
        templateUrl: 'templates/tab-bag.html',
        controller: 'BagsCtrl'
      }
    }
  })

  .state('tab.select', {
    url: '/select_sort_method',
    views: {
      'tab-bag': {
        templateUrl: 'templates/tab-select.html',
        controller: 'BagsCtrl'
      }
    }
  })


  // more info about an item, such as a recipe or a foodstuff
  .state('tab.iteminfo', {
    url: '/iteminfo/:id',
    views: {
      'tab-bag': {
        templateUrl: 'templates/item-info.html',
        controller: 'ItemInfoCtrl'
      }
    }
  })

  .state('tab.picks', {
      url: '/picks',
      views: {
        'tab-picks': {
          templateUrl: 'templates/tab-picks.html',
          controller: 'PicksCtrl'
        }
      }
    })
    .state('tab.chat-detail', {
      url: '/chats/:chatId',
      views: {
        'tab-chats': {
          templateUrl: 'templates/chat-detail.html',
          controller: 'ChatDetailCtrl'
        }
      }
    })

  .state('tab.account', {
    url: '/account',
    views: {
      'tab-account': {
        templateUrl: 'templates/tab-account.html',
        controller: 'AccountCtrl'
      }
    }
  });

  // if none of the above states are matched, use this as the fallback
  $urlRouterProvider.otherwise('/tab/bag');

});
