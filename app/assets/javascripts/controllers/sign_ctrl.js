app.controller('SignCtrl', ['$scope', '$http', '$routeParams', function($scope, $http, $routeParams) {
  $scope.sign_in = function (form) {
    $http.post('/users/sign_in', form)
      .success(function () {
        window.location.reload();
      })
  }

  $scope.sign_up = function (form) {
    $http.post('/users', form)
      .success(function (res) {
        window.location = '/profile/'+res.user_id+'?page=edit'
      })
  }
}])