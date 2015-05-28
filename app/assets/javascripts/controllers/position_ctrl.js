app.controller('PositionCtrl', ['$scope', '$routeParams', '$location', '$timeout', '$http', 'Position', 'Offer', 'Search', 'Data', 'User', '$rootScope', function($scope, $routeParams, $location, $timeout, $http, Position, Offer, Search, Data, User, $rootScope) {
  $scope.Position = Position;
  $scope.Offer = Offer;
  $scope.type = $location.search().type;

  if ($location.path()=='/positions') {
    $rootScope.positions_page = true;
    $scope.$on("$destroy", function(){
        $rootScope.positions_page = false;
    });
    
    if (_.isUndefined($location.search().type)) {
      $location.search({type: 'positions', status: 'opened'});
    }

    $scope.$watch(function () {
      return $location.search()
    }, function (search) {
      $scope.type = search.type;
      $scope.status = search.status;
      if ($scope.type=='positions') {
        Position.get({status: $scope.status, type: $scope.type}, function (res) {
          Position.positions = res.positions;
          Data.statuses = res.statuses;
        });
      } else if ($scope.type=='offers') {
        Offer.get({status: $scope.status, type: $scope.type}, function (res) {
          Position.positions = res.positions;
          Data.offers_statuses = res.offers_statuses;
        });
      }
    }, true);

    $scope.$watch('status', function (val) {
      if (!_.isUndefined(val)) {
        if ($scope.type=='positions'){
          $location.search({type: 'positions', status: val})
          if (val == 1) {
            Offer.resetCounter()
          }
        } else if ($scope.type=='offers') {
          $location.search({type: 'offers', status: val})
        }
      }
    })
  }


  if (!_.isUndefined($routeParams.id)) {
    Position.get({id: $routeParams.id}, function (res) {
      Search.position_info = res.position_info;
      Search.suitable_list = res.suitable_list
    })
  }
}])