app.directive('pickAddress', ['$http', '$rootScope', '$location', '$timeout', function($http, $rootScope, $location, $timeout) {
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {
      form: '=form',
      isShow: '=isShow',
      draggable: '=draggable'
    }, // {} = isolate, true = child, false/undefined = no change
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    restrict: 'E', // E = Element, A = Attribute, C = Class, M = Comment
    template: document.getElementById('pick_address').innerHTML,
    // templateUrl: '',
    replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
    link: function($scope, iElm, iAttrs, controller) {
      $scope.$watch('isShow', function (val) {
        if (val) {
          $rootScope.blurContent = true;
          $scope.pickAddress = {
            address: $scope.form.address,
            lat: $scope.form.lat || 0,
            lng: $scope.form.lng || 0,
            city: $scope.form.city
          }
          if (window.map_modal_layer!=undefined) {
            var coords = [$scope.form.lat || 0, $scope.form.lng || 0];
            marker.setLatLng(coords)
            map_modal_layer.setView(coords)
            initialize();
          }
          $timeout(function () {
            map_modal_layer.invalidateSize()
          })
        } else if (val===false){
          $rootScope.blurContent = false;
        }
      })

      $scope.$watch('draggable', function (val) {
        if (val != undefined)
          initialize();
      })

      $scope.$watch(function () {
        return $location.url()
      }, function () {
        $scope.isShow = false;
      })
      
      $scope.apply = function () {
        $rootScope.$broadcast('pickAddress', $scope.pickAddress)
        $scope.isShow = false;
      }

      var marker;
      
      function initialize () {
        if (window.map_modal_layer) map_modal_layer.remove();
        
        window.map_modal_layer = L.mapbox.map('map_modal', 'storuky.bb38e7c8', {
              zoomControl: false,
              maxBounds: [[90,-220],[-90, 220]],
              // attributionControl: false
            })
            .setView([$scope.form.lat || 52.93539665862318, $scope.form.lng || 36.3427734375], 5);

        marker = L.marker([$scope.form.lat || 52.93539665862318, $scope.form.lng || 36.3427734375], {
            icon: L.divIcon({
              html: "<div class='marker-label cluster'><div class='marker-label__body'>Местоположение</div></div>"
            }),
            draggable: $scope.draggable
        });
        marker.addTo(map_modal_layer);

        marker.on('dragend', function (e) {
          geo(e.target._latlng.lat, e.target._latlng.lng);
        })

        if ($scope.draggable) {
          map_modal_layer.on('click', function(e) {
            marker.setLatLng(e.latlng);
            geo(e.latlng.lat, e.latlng.lng);
          });
        }
      }


      var geo = function (lat, lng) {
        $http.jsonp("http://geocode-maps.yandex.ru/1.x/?geocode="+lng+","+lat+"&format=json&callback=JSON_CALLBACK").success(function (res) {
          $scope.pickAddress = {
            city: res.response.GeoObjectCollection.featureMember[0].GeoObject.description,
            lat: lat,
            lng: lng,
            address: res.response.GeoObjectCollection.featureMember[0].GeoObject.name
          }
        })
      }
    }
  };
}]);