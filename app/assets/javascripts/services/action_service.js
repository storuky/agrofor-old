app.service('Action', ['$rootScope', function ($rootScope) {
  var Action = this;

  Action.confirm = function (message, callback) {
    Action.confirm_show = true;
    Action.confirm_message = message;

    document.getElementById('confirm_yes').onclick = function () {
      callback(true);
      Action.confirm_show = false;
    }

    document.getElementById('confirm_no').onclick = function () {
      // callback(false);
      Action.confirm_show = false;
    }

    $rootScope.$watch(function () {
      return Action.confirm_show
    }, function (v) {
      $rootScope.blurContent = v;
    })
  }
}])