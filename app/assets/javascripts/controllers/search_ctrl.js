app.controller('SearchCtrl', ['$scope', '$rootScope', '$routeParams', '$timeout', '$location', 'Search', 'Data', 'Position', function($scope, $rootScope, $routeParams, $timeout, $location, Search, Data, Position) {
  $rootScope.searchPage = true;
  $scope.$on("$destroy", function(){
      $rootScope.searchPage = false;
  });

  Position.get({status: 'opened', type: 'positions'}, function (res) {
    Search.suitPositions = res.positions;
    $scope.$watch(function () {
      return Search.suitPositionsChecked
    }, _.debounce(function (n, o) {
      if (n) {
        Search.suitPositionsCheckedCount = window.pickTrue(n).length;
        if (Search.suitPositionsCheckedCount) {
          Search.find_suitable();
        } else {
          if (!Search.result || !Search.result.length)
            Search.find_all()
        }
      }
    }, 300), true)
  });

  $scope.ngInclude = '/ajax/search/' + $routeParams.type;

  switch ($routeParams.type) {
    case 'map':
                Search.view = 1;
                break;
    case 'list':
                Search.view = 2;
                break;
  }

  $scope.setSearchPopup = function (popup) {
    if ($scope.activeSearchParams == popup) {
      $scope.activeSearchParams = '';
    } else {
      $scope.activeSearchParams = popup;
    }
  }

  $scope.$watch(function () {
    return Search.view
  }, function (view) {
    if (view) {
      $location.path('/search/'+Data.search_view_group[view].value)
    }
  })

  $scope.$watch(function () {
    return Search.form.query
  }, _.debounce(function (n, o) {
    if (!_.isUndefined(n)) {
      if (!n.length) {
        Search.form.query = undefined;
        Search.find_all();
      } else {
        Search.find_by_params();
      }
    }
  }, 300), true)

}])