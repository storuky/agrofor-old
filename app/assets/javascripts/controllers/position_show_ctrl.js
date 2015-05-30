app.controller('PositionShow', ['$scope', '$routeParams', '$http', '$timeout', 'Search', 'Offer', '$location', function($scope, $routeParams, $http, $timeout, Search, Offer, $location) {
  angular.element(document.querySelector('.position__suitable__select'))
  .bind('mouseleave', function (event) {
    $scope.timeout = $timeout(function () {
      $scope.suitableShow = false;
      $scope.$apply();
    }, 500)
  })
  .bind('mousemove', function (event) {
    $timeout.cancel($scope.timeout)
  })

  $scope.toggleSuitable = function () {
    if (Search.suitable_list.length) {
      $scope.suitableShow = !$scope.suitableShow;
    } else {
      $location.url('/positions/new?offer='+($location.search().id || $routeParams.id))
    }
  }

  $scope.$watch(function () {
    return $location.search().type
  }, function (type) {
    $scope.isRate = type=='rate'
  })

  $scope.resetSerch = function () {
    $location.search({})
  }

  $scope.$watch(function () {
    return Search.suitable_list
  }, function (val) {
    if (val) {
      $scope.suitableCurrent = val[0];
    }
  })

  $scope.$watch(function () {
    return Search.position_info.photos
  }, function (val) {
    $timeout(function () {
      dcboxInit();
    })
  }, true)

  $scope.sendOffer = function () {
    if (!$scope.sendInProgress){
      $scope.sendInProgress = true;
      Offer.send($location.search().id || $routeParams.id, $scope.suitableCurrent.id, function () {
        $scope.sendInProgress = false;
      })
    }
  }

  $scope.suitableCheck = function (position, $event) {
    $scope.suitableCurrent = position;
  }
}])