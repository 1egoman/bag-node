# Ionic Starter App
# angular.module is a global place for creating, registering and retrieving Angular modules
# 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
# 'starter.services' is found in services.js
# 'starter.controllers' is found in controllers.js
angular.module 'bag', [
  'ionic'
  'jett.ionic.filter.bar'
  'ngTagsInput'
  'ngCordova'
  'bag.controllers'
  'bag.services'
  'bag.directives'
]
  
.run ($ionicPlatform, $ionicConfig, $rootScope, auth) ->

  # ionic stuff
  $ionicPlatform.ready ->

    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    # for form inputs)
    if window.cordova and window.cordova.plugins and window.cordova.plugins.Keyboard
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar true
      cordova.plugins.Keyboard.disableScroll true

    if window.StatusBar
      # org.apache.cordova.statusbar required
      StatusBar.styleLightContent()

  # change the statusbar so it looks a little better
  # $cordovaStatusbar.overlaysWebView(false)
  # $cordovaStatusBar.style(1) //Light
  # $cordovaStatusBar.style(2) //Black, transulcent
  # $cordovaStatusBar.style(3) //Black, opaque
  
  $ionicConfig.tabs.position 'bottom'
  # Places them at the bottom for all OS

  $ionicConfig.tabs.style 'standard'
  # Makes them all look the same across all OS


  # lastly, should we hide or show bottom tab bar?
  # hide only if we aren't authorized
  $rootScope.hideTabs = not auth.success

.config ($stateProvider, $urlRouterProvider, authProvider) ->

  $stateProvider
  
  # each tab has its own nav history stack
  .state 'tab',
    url: '/tab'
    abstract: true
    templateUrl: 'templates/tabs.html'


  # tutorial on how to us the app
  .state 'tab.howtouse',
    url: '/howtouse'
    views:
      'view-auth':
        templateUrl: 'templates/auth/howtouse.html'
        controller: 'onboardCtrl'


  # if auth was successful, then register the whole gambit of routes
  if authProvider.getSuccess()

    $stateProvider
    
    # bag tab
    .state 'tab.bag',
      url: '/bag'
      views:
        'tab-bag':
          templateUrl: 'templates/tab-bag.html'
          controller: 'BagsCtrl'

    .state 'tab.select',
      url: '/select_sort_method'
      views:
        'tab-bag':
          templateUrl: 'templates/tab-select.html'
          controller: 'BagsCtrl'

    # more info about an item, such as a recipe or a foodstuff
    .state 'tab.iteminfo',
      url: '/iteminfo/:id'
      views:
        'tab-bag':
          templateUrl: 'templates/item-info.html'
          controller: 'ItemInfoCtrl'



    # user picks tab
    .state 'tab.picks',
      url: '/picks'
      views:
        'tab-picks':
          templateUrl: 'templates/tab-picks.html'
          controller: 'PicksCtrl'


    # user recipes tab
    .state 'tab.recipes',
      url: '/recipes'
      views:
        'tab-picks':
          templateUrl: 'templates/tab-recipes.html'
          controller: 'RecipesCtrl'


    # recipe info
    # this will open in the recipe stack and not the bag one
    .state 'tab.recipeinfo',
      url: '/recipeinfo/:id'
      views:
        'tab-picks':
          templateUrl: 'templates/item-info.html'
          controller: 'ItemInfoCtrl'



    # settings page - still mostly stock
    .state 'tab.account',
      url: '/account'
      views:
        'tab-account':
          templateUrl: 'templates/tab-account.html'
          controller: 'AccountCtrl'


    .state 'tab.stores',
      url: '/stores'
      views:
        'tab-account':
          templateUrl: 'templates/tab-store-picker.html'
          controller: 'StorePickerCtrl'


    # if none of the above states are matched, use this as the fallback
    $urlRouterProvider.otherwise '/tab/bag'

  # If the user isn't logged in / hasn't created an account with us yet....
  else
    $stateProvider
      

    .state 'tab.onboard',
      url: '/onboarding/:step'
      views:
        'view-auth':
          templateUrl: 'templates/auth/onboard.html'
          controller: 'onboardCtrl'



    # login page
    .state 'tab.login',
      url: '/login'
      views:
        'view-auth':
          templateUrl: 'templates/auth/login.html'
          controller: 'authCtrl'

    $urlRouterProvider.otherwise '/tab/login'

# convert to titlecase
# like 'hello world' -> 'Hello World'
.filter 'titlecase', ->
  (input) ->
    input = input or ''
    smallWords = /^(a|an|and|as|at|but|by|en|for|if|in|nor|of|on|or|per|the|to|vs?\.?|via)$/i
    input.replace /[A-Za-z0-9\u00C0-\u00FF]+[^\s-]*/g, (match, index, title) ->
      if index > 0 and index + match.length != title.length and match.search(smallWords) > -1 and title.charAt(index - 2) != ':' and (title.charAt(index + match.length) != '-' or title.charAt(index - 1) == '-') and title.charAt(index - 1).search(/[^\s-]/) < 0
        return match.toLowerCase()
      if match.substr(1).search(/[A-Z]|\../) > -1
        return match
      match.charAt(0).toUpperCase() + match.substr(1)
