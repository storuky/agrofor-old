app.directive('messageModal', ['$rootScope', '$http', '$location', function($rootScope, $http, $location) {
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {
      user: '=user',
      isShow: '=isShow'
    }, // {} = isolate, true = child, false/undefined = no change
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    // restrict: 'A', // E = Element, A = Attribute, C = Class, M = Comment
    template: document.getElementById('new_message_tmpl').innerHTML,
    // templateUrl: '',
    // replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
    link: function($scope, iElm, iAttrs, controller) {
      $scope.$watch('isShow', function (isShow) {
        if (isShow) {
          $http.get('/ajax/correspondences/with?user_id='+$scope.user.id)
            .success(function (res) {
              $location.url('/correspondences?type=users&id='+res.id)
            })
            .error(function () {
              $rootScope.blurContent = isShow;
            })
        } else {
          $rootScope.blurContent = false;
        }
      })

      $scope.startConvertation = function (msg, id) {
        $http.post('/ajax/correspondences/start', {msg: msg, id: id})
          .success(function (res) {
            $location.url('/correspondences?type=users&id='+res.id);
            $scope.isShow = false;
            $scope.msg = "";
          })
      }
    }
  };
}]);