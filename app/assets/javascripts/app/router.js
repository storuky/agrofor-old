app.config(['$routeProvider', '$httpProvider', '$locationProvider', function ($routeProvider, $httpProvider, $locationProvider) {
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = document.querySelector('meta[name=csrf-token]').content;
  $locationProvider.html5Mode(true).hashPrefix('!');

  if (gon.user.id)
    $routeProvider
      .when('/positions', {
        templateUrl: '/ajax/positions',
        controller: 'PositionCtrl',
        reloadOnSearch: false
      })
      .when('/positions/new', {
        templateUrl: '/ajax/positions/form',
        controller: 'PositionCtrl',
        reloadOnSearch: false
      })
      .when('/positions/:id/edit', {
        templateUrl: '/ajax/positions/form',
        controller: 'PositionCtrl',
        reloadOnSearch: false
      })
      .when('/correspondences', {
        templateUrl: '/ajax/correspondences',
        controller: 'CorrespondencesCtrl',
        reloadOnSearch: false
      })
      .when('/help', {
        templateUrl: '/ajax/help',
        controller: 'PositionCtrl',
        reloadOnSearch: false
      })
      .when('/settings', {
        templateUrl: '/ajax/settings',
        controller: 'PositionCtrl',
        reloadOnSearch: false
      })
      .when('/users/:type', {
        template: "",
        controller: 'SignCtrl'
      })
      .when('/terms-and-conditions', {
        templateUrl: "/ajax/terms/terms",
        controller: 'TermsCtrl'
      })
      .when('/privacy-policy', {
        templateUrl: "/ajax/terms/privacy",
        controller: 'PrivacyCtrl'
      })

  if (!gon.user.id)
    $routeProvider
      .when('/positions/new', {
        redirectTo: '/search/map'
      })

  $routeProvider
    .when('/search/:type', {
      templateUrl: '/ajax/search',
      controller: 'SearchCtrl',
      reloadOnSearch: false
    })
    .when('/positions/:id', {
      templateUrl: '/ajax/positions/show',
      controller: 'PositionCtrl',
      reloadOnSearch: false
    })
    .when('/profile/:id', {
      templateUrl: '/ajax/profile',
      controller: 'ProfileCtrl as profile',
      reloadOnSearch: false
    })
    .otherwise({
      redirectTo: '/search/map'
    })
}]);