angular.module 'starter.directives', []
  
.directive 'recipeCard', ->
  restrict: 'E'
  templateUrl: '/templates/recipe-card.html'
  require: '^recipe'
  scope:
    recipe: '='
    change: '='
    sortOpts: '='
    deleteItem: '&'
    moreInfo: '&'

.directive 'checkableItem', ->
  restrict: 'E'
  templateUrl: '/templates/checkable-item.html'
  require: '^item'
  scope:
    item: '='
    change: '='
    sortOpts: '='
    deleteItem: '&'
    moreInfo: '&'
