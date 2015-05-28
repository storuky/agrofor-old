app.directive('categories', ['$rootScope', '$timeout', '$location', 'Data', 'pluralize', function($rootScope, $timeout, $location, Data, pluralize) {
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {
      isShow: '=isShow'
    }, // {} = isolate, true = child, false/undefined = no change
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    restrict: 'E', // E = Element, A = Attribute, C = Class, M = Comment
    template: categories_tmpl.innerHTML,
    // templateUrl: '',
    // replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
    link: function($scope, iElm, iAttrs, controller) {
      $scope.category_columns = gon.data.categories;

      $scope.setActiveOptions = function (option) {
        if (_.isArray($scope.activeOpions)) {
          var index = $scope.activeOpions.indexOf(option.id);
          
          if (index!=-1) {
            $scope.activeOpions.splice(index, 1);
          } else {
            $scope.activeOpions.push(option.id);
          }
        } else {
          $scope.activeOpions = option.id;
        }
      }

      $scope.isActive = function (id) {
        if (_.isArray($scope.activeOpions)) {
          return $scope.activeOpions.indexOf(id)!=-1;
        } else {
          return $scope.activeOpions == id;
        }
      }

      $scope.apply = function () {
        $scope.form[$scope.key] = _.clone($scope.activeOpions);
        $scope.activeOpions = [];
        $scope.isShow = false;
      }

      $rootScope.showCategoryModal = function (form, key, multiple) {
        $scope.form = form;
        $scope.activeOpions = form[key] || (multiple ? [] : undefined);
        
        $scope.key = key;
        $scope.isShow = true;
      }

      $scope.$watch('isShow', function (v) {
        if (v) {
          $timeout(function () {
            iElm[0].querySelector('input[type="text"]').focus();
          }, 100);
          $rootScope.blurContent = true;
        } else if (v===false) {
          $rootScope.blurContent = false;
        }
      });

      $scope.$watch(function () {
        return $location.url()
      }, function () {
        $scope.isShow = false;
      })
    }
  };
}]);