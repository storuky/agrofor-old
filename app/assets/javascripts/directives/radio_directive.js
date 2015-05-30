app.directive('radio', [function(){
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {
      ngModel: '=ngModel',
      options: '=options',
      allowNull: '=allowNull',
      count: "=count"
    },
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    // restrict: 'A', // E = Element, A = Attribute, C = Class, M = Comment
    template: '<span class="radio">'
                + '<span class="radio__btn" ng-click="setActiveOption(option.id)" ng-class="{active:option.id==ngModel, red: option.color==\'red\', green: option.color==\'green\'}" ng-repeat="option in options">'
                  +'{{::option.title}}'
                  + '<strong ng-show="count[option.id]">'
                    +'+{{count[option.id]}}'
                  + '</strong>'
                + '</span>'
             +'</span>',
    // templateUrl: '',
    replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
    link: function($scope, iElm, iAttrs, controller) {
      $scope.setActiveOption = function (id) {
        if ($scope.allowNull) {
          $scope.ngModel = $scope.ngModel!=id ? id : undefined;
        } else {
          $scope.ngModel = id;
        }
      }
    }
  };
}]);