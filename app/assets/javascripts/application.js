// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.

//= require perfect-scrollbar.min
// require jquery-1.11.2.min
//= require dcbox
//= require angular
//= require angular-locale_ru-ru
//= require angular-route
//= require angular-resource
//= require angular-animate
//= require websocket_rails/main
//= require underscore
//= require private_pub
//= require_self
//= require_tree .

L.mapbox.accessToken = 'pk.eyJ1Ijoic3RvcnVreSIsImEiOiI3d3BNZVg4In0.ko_gVvDKCQGn_z9QbftZUA';


var app = angular.module('app', ['ngRoute', 'ngResource', 'ngAnimate', 'ngNotify']);

app.run(['$rootScope', 'Search', 'Data', 'User', 'Offer', 'Message', 'Position', 'pluralize', 'ngNotify', 'Action', '$timeout', 'Validate', function($rootScope, Search, Data, User, Offer, Message, Position, pluralize, ngNotify, Action, $timeout, Validate){
  $rootScope._ = _;
  $rootScope.Data = Data;
  $rootScope.User = User;
  $rootScope.Position = Position;
  $rootScope.Offer = Offer;
  $rootScope.Message = Message;
  $rootScope.Search = Search;
  $rootScope.Action = Action;
  $rootScope.pluralize = pluralize;
  $rootScope.$watch('[showSign]', function(val) {
    $rootScope.blurContent = !!_.compact(val).length;
  });

  ngNotify.config({
      theme: 'pure',
      position: 'top',
      duration: 2000,
      type: 'info',
      // sticky: true
  });

  $rootScope.$on('loading:finish', function (h, res) {
    if (res.data && res.data.msg) {
      ngNotify.set(res.data.msg, 'success');
    }
  })

  $rootScope.$on('loading:error', function (h, res) {
    if (res.data) {
      if (res.data.msg) {
        ngNotify.set(res.data.msg, 'error');
      }
      if (res.data.errors) {
        Validate(res.data.errors)
      }
    }
  })

  $rootScope.$on('$routeChangeStart', function(next, current) { 
     $rootScope.animInProgress = true;
     $timeout(function () {
      $rootScope.animInProgress = false;
     }, 600)
  });

  Offer.new_offers_count = User.data.new_offers_count;
}]);

// app.run(['$rootScope', '$templateCache', function($rootScope, $templateCache) {
//    $rootScope.$on('$viewContentLoaded', function() {
//       $templateCache.removeAll();
//    });
// }]);

app.run(['$rootScope', '$http', '$interval', 'Data', function($rootScope, $http, $interval, Data) {
  $rootScope.sign_out = function () {
    $http({method: 'DELETE', url: '/users/sign_out'})
      .success(function () {
        window.location = "/";
      })
      .error(function () {
        window.location = "/";
      })
  }

  $interval(function () {
    $http.get('/currencies/current_rates')
      .success(function (res) {
        Data.rates = res.rates;
      })
  }, 1000*60*60)
}])

app.config(['$compileProvider', function($compileProvider){
  $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|file|javascript|blob):/);
}]);