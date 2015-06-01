app.directive('searchList', ['User', 'Data', 'Search', 'Position', function(User, Data, Search, Position) {
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {
      positions: "=positions"
    }, // {} = isolate, true = child, false/undefined = no change
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    // restrict: 'A', // E = Element, A = Attribute, C = Class, M = Comment
    template: document.getElementById('search_list').innerHTML,
    // templateUrl: '',
    replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
    link: function($scope, iElm, iAttrs, controller) {
      $scope.User = User;
      $scope.Search = Search;
      $scope.Data = Data;
      $scope.Position = Position;
    }
  };
}]);