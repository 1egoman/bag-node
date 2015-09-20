# Ionic Starter App
# angular.module is a global place for creating, registering and retrieving Angular modules
# 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
# 'starter.services' is found in services.js
# 'starter.controllers' is found in controllers.js
angular.module 'bag', [
  'ui.router'

  'bag.controllers'
  'bag.services'
  'bag.directives'
]

.config ($stateProvider, $urlRouterProvider, authProvider) ->

  # $stateProvider
  #
  # # each tab has its own nav history stack
  # .state 'tab',
  #   url: '/tab'
  #   abstract: true
  #   templateUrl: 'templates/tabs.html'
  #
  #
  # # tutorial on how to us the app
  # .state 'tab.howtouse',
  #   url: '/howtouse'
  #   views:
  #     'view-auth':
  #       templateUrl: 'templates/auth/howtouse.html'
  #       controller: 'onboardCtrl'


  # if auth was successful, then register the whole gambit of routes
  if authProvider.getSuccess()

    $stateProvider
    
    # bag tab
    .state 'bag',
      url: '/bag'
      templateUrl: 'templates/tab-bag.html'
      controller: 'BagsCtrl'

    .state 'select',
      url: '/select_sort_method'
      templateUrl: 'templates/tab-select.html'
      controller: 'BagsCtrl'

    # more info about an item, such as a recipe or a foodstuff
    .state 'tab.iteminfo',
      url: '/iteminfo/:id'
      views:
        main:
          templateUrl: 'templates/item-info.html'
          controller: 'ItemInfoCtrl'



    # user picks tab
    .state 'picks',
      url: '/picks'
      templateUrl: 'templates/tab-picks.html'
      controller: 'PicksCtrl'


    # user recipes tab
    .state 'tab.recipes',
      url: '/recipes'
      views:
        main:
          templateUrl: 'templates/tab-recipes.html'
          controller: 'RecipesCtrl'


    # recipe info
    # this will open in the recipe stack and not the bag one
    .state 'tab.recipeinfo',
      url: '/recipeinfo/:id'
      views:
        main:
          templateUrl: 'templates/item-info.html'
          controller: 'ItemInfoCtrl'



    # settings page - still mostly stock
    .state 'tab.account',
      url: '/account'
      views:
        main:
          templateUrl: 'templates/tab-account.html'
          controller: 'AccountCtrl'


    .state 'tab.stores',
      url: '/stores'
      views:
        main:
          templateUrl: 'templates/tab-store-picker.html'
          controller: 'StorePickerCtrl'


    .state 'add_recipe',
      url: '/add_recipe'
      templateUrl: 'templates/modal-add-recipe.html'



    # if none of the above states are matched, use this as the fallback
    $urlRouterProvider.otherwise '/bag'

  # If the user isn't logged in / hasn't created an account with us yet....
  else
    $stateProvider


    .state 'onboard',
      url: '/onboarding/:step'
      templateUrl: 'templates/auth/onboard.html'
      controller: 'onboardCtrl'



    # login page
    .state 'login',
      url: '/login'
      templateUrl: 'templates/auth/login.html'
      controller: 'authCtrl'


    $urlRouterProvider.otherwise '/login'

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
