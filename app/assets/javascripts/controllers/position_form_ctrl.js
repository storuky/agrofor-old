app.controller('PositionFormCtrl', ['$scope', '$http', '$rootScope', '$routeParams', '$location', '$timeout', 'Data', 'User', 'Position', 'Action', 'Search', function($scope, $http, $rootScope, $routeParams, $location, $timeout, Data, User, Position, Action, Search) {
  $scope.form = {
    lat: User.data.lat,
    lng: User.data.lng,
    city: User.data.city,
    address: User.data.address,
    currency_id: User.data.currency.id,
    price_discount: 5,
    updated_at: new Date()
  };

  $http.get('/ajax/positions/form.json')
    .success(function (res) {
      Data.templates = res.templates;
    })

  $scope.showPickAddress = function () {
    $rootScope.pickAddress = {
      draggable: true,
      isShow: true
    }
    $rootScope.pickAddress.form = $scope.form;
  }
  
  $rootScope.$on('pickAddress', function (e, v) {
    $scope.form = _.extend($scope.form, v);
  })

  $scope.deleteTemplate = function (id) {
    $http({method: 'DELETE', url: '/ajax/positions/templates?id='+id})
  }

  $scope.savePosition = function () {
    if (!$scope.disableBtn) {
      $scope.disableBtn = true;
      var formData = new FormData();
      _.each($scope.photos, function (el, num) {
        formData.append('photos[]', el);
      });

      _.each($scope.form, function (v, k) {
        if (k!='photos' && !!v)
          formData.append(k, v);
      });

      if ($scope.isEdit){
        $http({
          method: "PUT",
          url: '/ajax/positions/'+$routeParams.id+'.json',
          headers: {
            'Content-Type': undefined
          },
          data: formData
        }).success(function () {
          $location.url('/positions?type=positions&status=opened');
          $scope.disableBtn = false;
        }).error(function () {
          $scope.disableBtn = false;
        })
      } else {
        $http({
          method: "POST",
          url: '/ajax/positions',
          headers: {
            'Content-Type': undefined
          },
          data: formData
        }).success(function (res) {
          Search.suitPositionsChecked[res.position_id] = true;
          $location.url('/search/map');
          $scope.disableBtn = false;
        }).error(function () {
          $scope.disableBtn = false;
        })
      }
    }
  }

  $scope.closePosition = function () {
    Action.confirm(gon.translation.confirm.close_position, function (confirmed) {
      if (confirmed) {
        $http({method: 'PUT', url: '/ajax/positions/archive', data: {id: $routeParams.id}})
          .success(function (res) {
            $location.url('/positions?type=positions&status=archive');
          })
      }
    });
  }

  $scope.restorePosition = function () {
    Action.confirm(gon.translation.confirm.restore_position, function (confirmed) {
      if (confirmed) {
        $scope.disableBtn = true;
        $http({method: 'PUT', url: '/ajax/positions/restore', data: {id: $routeParams.id}})
          .success(function (res) {
            $location.url('/positions?type=positions&status=opened');
            $scope.disableBtn = false;
          })
          .error(function () {
            $scope.disableBtn = false;
          })
      }
    });
  }

  $scope.photos = [];
  $scope.photosSrc = [];
  $scope.$watch('photos_field', function (val) {
    if (val) {
      _.each(val, function (v, k) {
        $scope.form.photos = $scope.form.photos || [];
        $scope.form.photos.push({
          photo: {
            url: URL.createObjectURL(v),
            thumb: {
              url: URL.createObjectURL(v)
            }
          }
        })
        $scope.photos.push(v);
      })
    }
  }, true)

  $scope.deletePhoto = function (id, $index, $event) {
    if (_.isNumber(id)) {
      $http({method: "DELETE", url: "/ajax/positions/delete_photo", params: {id: id}})
        .success(function (res) {
          $scope.form.photos = res;
        })
    } else {
      $scope.form.photos.splice($index, 1);
      $scope.photos.splice($index, 1);
    }
    $event.preventDefault()
    $event.stopPropagation();
    return false;
  }

  $scope.$watch('template', function (id) {
    if (!_.isUndefined(id)) {
      $http.get('/ajax/positions/template?id='+id)
        .success(function (res) {
          $scope.form = res;
        })
    }
  })

  $scope.$watch('form.photos', function (val) {
    $timeout(function () {
      dcboxInit();
    });
  }, true)

  if ($location.search()["offer"]) {
    Position.get({id: $location.search()["offer"]}, function (res) {
      var form = _.pick(res.position_info, 'option_id', 'weight', 'weight_dimension_id', 'currency_id');
      _.extend($scope.form, form);
      $scope.form.trade_type = Data.trade_types_association[res.position_info.trade_type];
      $scope.form.currency_id = User.data.currency.id;
      $scope.form.price = res.position_info.price_in_currency || res.position_info.price;
    })
  }

  if ($location.path().indexOf('edit')!=-1) {
    $scope.isEdit = true;
    $http.get('/ajax/positions/'+$routeParams.id+'/edit.json')
      .success(function (res) {
        $scope.form = res;
      })
      .error(function (res) {
        $location.url('/positions');
      })
  }
}])