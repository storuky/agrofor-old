app.directive('ngSelect', ['$rootScope', '$timeout', 'pluralize', 'Data', function($rootScope, $timeout, pluralize, Data) {
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {
      options: '=options',
      ngModel: '=ngModel',
      multiple: '=multiple',
      category: '=category',
      placeholder: '=placeholder',
      onDelete: '=onDelete',
    }, // {} = isolate, true = child, false/undefined = no change
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    // restrict: 'A', // E = Element, A = Attribute, C = Class, M = Comment
    template: document.getElementById('select').innerHTML,
    // templateUrl: '',
    replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs) {
    //   return function linking ($scope, element, iAttrs) {
    //     // body...
    //   }
    // },
    link: function($scope, element, iAttrs, controller) {
      var uid = window.guid();
      if ($scope.category) {
        var options = Data.options;
      }

      $scope._ = _;

      $scope.$watch('ngModel', function (model) {
        if ($scope.category && _.isArray($scope.ngModel) && !$scope.multiple) {
          $scope.ngModel = model[0];
        }

        if (!_.isUndefined(model)) {
          if (_.isArray(model)) {
            if (model.length==1) {
              var title = _.find($scope.options || options, function (val) {
                return val.id == model[0];
              });
              $scope.title = title.title_locale || title.title;
            } else {
              $scope.title = model.length + " " + pluralize(model.length, gon.translation.category.plur)
            }
          } else {
            var title = _.find($scope.options || options, function (val) {
              return val.id == model;
            });

            $scope.title = title.title_locale || title.title;
          }
          $scope.isShow = false;
        } else {
          $scope.title = undefined;
        }
      }, true);

      $scope.checkModel = function (model) {
        if (!$scope.multiple) {
          $scope.ngModel = model;
        } else {
          $scope.ngModel = $scope.ngModel || [];
          var index = $scope.ngModel.indexOf(model);
          if (index!=-1)
            $scope.ngModel.splice(index, 1);
          else
            $scope.ngModel.push(model)
        }

      }

      $scope.isActive = function (id) {
        if (_.isArray($scope.ngModel)) {
          return $scope.ngModel.indexOf(id)!=-1
        } else {
          return $scope.ngModel==id; 
        }
      }

      $scope.deleteCategory = function (id, $index) {
        $scope.options.splice($index, 1);

        $scope.onDelete(id);
      }

      angular.element(element[0].querySelector('.select__checked'))
        .bind('click', function () {
          $rootScope.$broadcast('closePopup', {uid: uid})
          $rootScope.$on('closePopup', function (event, args) {
            if (args.uid!=uid)
              $scope.isShow = false;
          })
          $scope.isShow = !$scope.isShow;
          $scope.$apply();
        })

      element
        .bind('click', function (event) {
          event.stopPropagation();
        })
        .bind('mouseleave', function (event) {
          self.timeout = $timeout(function () {
            $scope.isShow = false;
            $scope.$apply();
          }, 500)
        })
        .bind('mousemove', function (event) {
          $timeout.cancel(self.timeout)
        })

      angular.element(document.body)
        .bind('click', function () {
            $scope.isShow = false;
            $scope.$apply();
        })

      $scope.$on("$destroy", function(){
          $rootScope.overflow = false;
      });
    }
  };
}]);