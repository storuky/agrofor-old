app.service('Search', ['$rootScope', '$location', '$routeParams', '$http', '$timeout', 'Position', 'User', function($rootScope, $location, $routeParams, $http, $timeout, Position, User) {
  var Search = this;

  Search.suitPositionsChecked = {};
  Search.form = {};
  Search.position_info = {}

  Search.find_by_params = function (page, fn) {
    var form = _.pick(Search.form, function (v, k) {
      return v;
    })
    var data = {
      position: form,
      marker: $rootScope.mapPage
    };

    if (page) {
      data.page = page;
    } else {
      Search.topPosition = false;
    }

    if (_.compact(Search.form).length>1) {
      loader.start();

      $http({method: "POST", url: "/search/by_params", data: data})
        .success(function (res) {
          Search.bound = true;
          if (fn)
            fn(res);
          else
            Search.update(res);
          if (!page)
            Search.scrollTop();
          loader.stop();
          angular.element(document.querySelectorAll('.errors')).remove();
        })
        .error(function (res) {
          loader.stop();
        })
    } else {
      Search.find_all();
    }
    Search.type = 'find_by_params';
  }

  Search.find_all = function (page, fn) {
    var params = {
      marker: $routeParams.type == 'map'
    };
    if (page) {
      params.page = page;
    } else {
      Search.topPosition = false;
    }

    loader.start();
    $http({method: "GET", url: "/search/all", params: params})
      .success(function (res) {
        Search.bound = false;
        if (fn)
          fn(res)
        else
          Search.update(res)

        if (!page)
          Search.scrollTop();
        loader.stop();
      })
    Search.type = 'find_all';
  }

  Search.find_suitable = function (page, fn) {
    var positions = _.filter(Search.suitPositions, function (position) {
      return _.contains(window.pickTrue(Search.suitPositionsChecked), position.id+"");
    });

    var position_ids = _.map(positions, function (position) {
      return position.id
    });
    
    var data = {
      position_ids: position_ids,
      marker: $rootScope.mapPage
    };

    if (page) {
      data.page = page;
    } else {
      Search.topPosition = false;
    }

    loader.start();
    $http({method: "POST", url: "/search/suitable", data: data})
      .success(function (res) {
        Search.bound = true;
        if (fn)
          fn(res);
        else
          Search.update(res)
        if (!page)
          Search.scrollTop();
        loader.stop();
      })
      Search.type = 'find_suitable';
  }

  Search.update = function (res) {
    if ($rootScope.mapPage)
      Search.markers = res;
    else {
      Search.result = res.positions;
      Search.favorites = res.favorites;
    }
  }

  Search.reset = function () {
    Search.form = {weight_dimension: 1}
    Search.find_all()
  }

  Search.toggleFavorite = function (id, $event) {
    $http.get('/ajax/positions/toggle_favorite?id='+id)
      .success(function (res) {
        User.data.favorite_ids = res;
      })
    if ($event) {
      $event.stopPropagation();
      $event.preventDefault();
      return false;
    }
  }

  Search.scrollTop = function () {
    var element = document.querySelector('.search__list__wrapper');
    if (element)
      element.scrollTop = 0
  }

  var timeout1, timeout2, timeout3, loader = {}, search_preloder;

  loader.start =function () {
    search_preloder = search_preloder || document.querySelector('.search__input__preloader');

    angular.element(search_preloder).removeClass('active-2s')
    angular.element(search_preloder).removeClass('active-3s')
    angular.element(search_preloder).removeClass('active-stop')
    
    timeout2 = $timeout(function () {
      angular.element(search_preloder).addClass('active-2s')
    }, 1)
    
    timeout3 = $timeout(function () {
      angular.element(search_preloder).addClass('active-3s')
    }, 2000)
  }

  loader.stop = function () {
    angular.element(search_preloder).addClass('active-stop')
  }

}])