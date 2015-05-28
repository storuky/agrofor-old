app.controller('SettingsCtrl', ['$scope', '$http', 'User', function($scope, $http, User){
  $scope.form = {
    currency_id: User.data.currency.id,
    locale: User.data.locale,
    sms_notify: User.data.sms_notify,
    email_notify: User.data.email_notify
  }

  $scope.saveSettings = function () {
    $http.post('/ajax/settings', $scope.form)
      .success(function (res) {
        window.location.reload();
      })
  }
}])