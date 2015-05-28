app.controller('ListCtrl', ['$scope', 'Search', 'Position', function($scope, Search, Position){
  $scope.Position = Position;
  $scope.page = 1;

  $scope.$watch(function () {
    return Search.type
  }, function (res) {
    $scope.page = 1;
  })

  document.querySelector('.search__list__wrapper').onscroll = function (e) {  
    if (e.target.scrollHeight - e.target.offsetHeight - e.target.scrollTop < 10 && !$scope.inProgress && !Search.topPosition) {
      var scroll = document.querySelector('.search__list__wrapper').scrollTop;
      $scope.inProgress = true;
      Search[Search.type](parseInt($scope.page)+1, function (res) {
        $scope.page = res.page;
        $scope.inProgress = false;
        _.each(res.positions, function (position) {
          Search.result.push(position)
        })
        if (!res.positions.length) {
          Search.topPosition = true;
        }
      })
    }
  }
}])