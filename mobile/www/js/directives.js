angular.module('starter.directives', [])

.directive("recipeCard", function() {
  return {
    restrict: 'E',
    templateUrl: "/templates/recipe-card.html",
    require: "^recipe",
    scope: {
      recipe: '='
    }
  };
})
