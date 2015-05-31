app.controller('SignCtrl', ['$scope', '$http', '$routeParams', function($scope, $http, $routeParams) {
  $scope.sign_in = function (form) {
    if (!$scope.sign_in_progress) {
      $scope.sign_in_progress = true;
      $http.post('/users/sign_in', form)
        .success(function () {
          window.location.reload();
        })
        .error(function () {
          $scope.sign_in_progress = false;
        })
    }
  }

  $scope.sign_up = function (form) {
    if (!$scope.sign_in_progress) {
      $scope.sign_in_progress = true;
      $http.post('/users', form)
        .success(function (res) {
          window.location = '/profile/'+res.user_id+'?page=edit'
        })
        .error(function () {
          $scope.sign_in_progress = false;
        })
    }
  }
}])