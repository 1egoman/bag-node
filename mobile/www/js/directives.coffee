angular.module 'starter.directives', []
  
.directive 'recipeCard', ->
  restrict: 'E'
  templateUrl: 'templates/recipe-card.html'
  require: '^recipe'
  scope:
    recipe: '='
    change: '='
    sortOpts: '='
    deleteItem: '&'
    moreInfo: '&'

.directive 'checkableItem', ->
  restrict: 'E'
  templateUrl: 'templates/checkable-item.html'
  require: '^item'
  scope:
    item: '='
    change: '='
    sortOpts: '='
    deleteItem: '&'
    moreInfo: '&'

.directive "loadingSpinner", ->
  restrict: 'E'
  templateUrl: '/templates/spinner.html'
  scope:
    complete: '='
  controller: ($scope) ->

    # get a motivational message to display.
    $scope.motivationalMessage = _.sample([
      "Just a little bit longer"
      "It's worth the wait"
      "Pardon us"
      "We're a little slow today"
    ]) + '.'
