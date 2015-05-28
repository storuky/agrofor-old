app.directive('positionInfo', ['Data', 'Search', 'User', '$http', function (Data, Search, User, $http) {
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {
      form: "=form",
      isOffer: "=isOffer",
      isPosition: "=isPosition"
    }, // {} = isolate, true = child, false/undefined = no change

    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    restrict: 'E', // E = Element, A = Attribute, C = Class, M = Comment
    template: document.getElementById('position_show').innerHTML,
    // templateUrl: '',
    // replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
    link: function($scope, iElm, iAttrs, controller) {
      $scope.Data = Data;
      $scope.User = User;

      $scope.$watch('form', function (form) {
        if (form!=undefined) {
          $scope.comment = {
            position_id: form.id,
            offer_id: form.deal_with_id
          };
        }
      })

      if ($scope.isOffer) {
        $scope.form.deal_with = [Search.position_info]
      }

      $scope.saveReputation = function () {
        $http.post('/ajax/reputations', $scope.comment)
          .success(function (res) {
            $scope.form.reputation = res.reputation
          })
      }
    }
  };
}]);