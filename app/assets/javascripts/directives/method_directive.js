app.directive('ngSignin', ['$rootScope', '$location', 'User', 'ngNotify', function($rootScope, $location, User, ngNotify) {
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    // scope: {}, // {} = isolate, true = child, false/undefined = no change
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    restrict: 'A', // E = Element, A = Attribute, C = Class, M = Comment
    // template: '',
    // templateUrl: '',
    // replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
    link: function($scope, iElm, iAttrs, controller) {
      iElm.bind('click', function (event) {
        if (!User.data.id) {
          ngNotify.set(gon.translation.user.notice.not_auth, 'error');
          $rootScope.showSign = true;
          event.stopPropagation();
          event.preventDefault();
        } else if (!User.data.name || !User.data.lat || !User.data.address || !User.data.lng || !User.data.email || !User.data.phone.length) {
          if (!User.data.phone.length) ngNotify.set(gon.translation.user.notice.add_phone, 'error');
          if (!User.data.name) ngNotify.set(gon.translation.user.notice.enter_name, 'error');
          if (!User.data.email) ngNotify.set(gon.translation.user.notice.enter_email, 'error');
          if (!User.data.lat || !User.data.lng || !User.data.address) ngNotify.set(gon.translation.user.notice.enter_address, 'error');
          event.stopPropagation();
          event.preventDefault();
          $location.url('/profile/'+User.data.id+'?page=edit')
        }

        $rootScope.$apply();
      })
    }
  };
}]);