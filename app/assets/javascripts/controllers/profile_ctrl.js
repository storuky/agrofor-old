app.controller('ProfileCtrl', ['$rootScope', '$scope', '$routeParams', '$http', '$location', 'User', function($rootScope, $scope, $routeParams, $http, $location, User) {
  var profile = this;
  profile.editing = $location.search().page=='edit';
  profile.type = 'open';
  
  $rootScope.activePage = 'profile';
  $scope.addressModalTitle = "Местоположение пользователя";

  $scope.showPickAddress = function () {
    $rootScope.pickAddress = {
      draggable: profile.editing,
      isShow: true,
      form: profile.form
    }
  }

  $rootScope.$on('pickAddress', function (e, v) {
    profile.form = _.extend(profile.form, v);
  })

  $http.get('/ajax/profile/'+$routeParams.id).success(function (res) {
    $scope.User = {
      data: res.user_data
    };
    profile.form = res.user_data;
    profile.form.phone = profile.form.phone.length ? profile.form.phone : ['']
    profile.reputations = res.reputations;
  })
  if ($routeParams.id==User.data.id) {
    $scope.myProfile = true;
    $scope.$watch(function () {
      return $location.search().page
    }, function (v) {
      profile.editing = v=='edit';
      if (profile.editing)
        $scope.addressModalTitle = "Укажите ваше местоположение на карте"
    })

    profile.form = User.data;
    profile.form.phone = profile.form.phone.length ? profile.form.phone : ['']

    profile.save = function () {
      profile.form.phone = _.compact(profile.form.phone);
      $http({method: 'PUT', url: '/ajax/profile/edit', data: profile.form})
        .success(function (res) {
          profile.editing = false;
          User.data = res;
          User.data.additional = User.data.additional || "Дополнительная информация";
        })
    }


    $scope.$watch(function () {
      return profile.avatarChanged;
    }, function (val) {
      console.log(val)
      if (val) {
        profile.showSpinner = true;
        var fd = new FormData();
        fd.append('avatar', val[0]);
        $http.post('/ajax/profile/avatar', fd, {
            transformRequest: angular.identity,
            headers: {'Content-Type': undefined}
        })
        .success(function(res){
          profile.showSpinner = false;
          User.data = res;
        })
        .error(function(res){
          profile.showSpinner = false;
        });
      }
    })
  }
}])