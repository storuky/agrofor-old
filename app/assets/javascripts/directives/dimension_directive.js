app.directive('dimension', ['$rootScope', function($rootScope){
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {
      ngModel: '=ngModel',
      ngModelDimension: '=ngModelDimension',
      options: '=options',
      disabled: '=disabled',
      readonly: '=readonly',
      prefix: '=prefix',
      postfix: '=postfix',
      placeholder: '=placeholder'
    }, // {} = isolate, true = child, false/undefined = no change
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    // restrict: 'A', // E = Element, A = Attribute, C = Class, M = Comment
    template: '<span class="dimension-group">'
                + '<input ng-disabled="readonly" placeholder="{{::placeholder}}" ng-model="ngModel" type="text">'
                + '<span class="dimension">'
                  + '<span ng-class="{disabled:disabled}" ng-click="openDimension($event)" class="dimension__selected">{{prefix+optionTitle+postfix}}</span>'
                  + '<ul ng-show="showDimension" class="dimension__options">'
                    + '<li ng-repeat="option in options" ng-click="checkOption(option.id)" class="dimension__option" ng-class="{active: option.id==ngModelDimension}">'
                      + '<span class="dimension__selected__title">{{::option.title}}</span>'
                    + '</li>'
                  + '</ul>'
                + '</span>'
              + '</span>',
    // templateUrl: '',
    replace: true,
    // transclude: true,
    compile: function(tElement, tAttrs){
      var uid = window.guid();

      return function linking($scope, el, attrs){
        $scope.checkOption = function (id) {
          $scope.ngModelDimension = id;
          $scope.optionTitle = findById($scope.options, id).title;
          $scope.showDimension = false;
        }

        $scope.openDimension = function ($event) {
          if (!$scope.disabled) {
            var showDimension = $scope.showDimension;
            $rootScope.$broadcast('closePopup', {uid: uid});
            $rootScope.$on('closePopup', function (event, args) {
              if (args.uid!=uid)
                $scope.showDimension = false;
            });
            $scope.showDimension = !showDimension;
            $event.stopPropagation();
          }
        }

        $scope.$watchCollection('options', function (v) {
          if (v) {
            var id = _.isUndefined($scope.ngModelDimension) ? v[0].id : $scope.ngModelDimension;
            $scope.checkOption(id)            
          }
        })

        $scope.$watch('ngModelDimension', function (val) {
          if ($scope.options) {
            var id = _.isUndefined(val) ? $scope.options[0].id : val;
            $scope.checkOption(id)
          }
        })

        angular.element(document.querySelector('body')).bind('click', function () {
          $scope.showDimension = false;
          $scope.$apply();
        })

      }
    }
  };
}]);