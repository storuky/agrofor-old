app.directive('correspondencePosition', ['Data', 'Position', function(Data, Position){
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {
      isShow: "=isShow",
      type: "=type",
      form: "=form"
    }, // {} = isolate, true = child, false/undefined = no change
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    // restrict: 'A', // E = Element, A = Attribute, C = Class, M = Comment
    template: position_info.innerHTML,
    // templateUrl: '',
    replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
    link: function($scope, iElm, iAttrs, controller) {
      angular.element(document.body).bind('click', function () {
        $scope.isShow = false;
        $scope.$apply();
      })
      $scope.Position = Position;
      $scope.Data = Data;

      iElm.bind('click', function ($event) {
        $event.stopPropagation();
      })
    }
  };
}]);