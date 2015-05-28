app.controller('MapCtrl', ['$scope', '$rootScope', '$http', '$location', 'pluralize', 'Data', 'Search', 'Position', function($scope, $rootScope, $http, $location, pluralize, Data, Search, Position){
  var maxZoom = 15;

  $rootScope.mapPage = true;
  $scope.$on("$destroy", function(){
      $rootScope.mapPage = false;
  });

  Search[Search.type || 'find_all']();

  $scope.$watch('isShowPosition', function (val) {
    if (!val && !_.isUndefined(val))
      $location.search({});
  })

  window.showPosition = function (id) {
    $location.search({id: id})
    Search.positionInfoInProgress = true;
    Position.get({id: id}, function (res) {
      Search.positionInfoInProgress = false;
      Search.position_info = res.position_info;
      Search.suitable_list = res.suitable_list;
      $scope.isShowPosition = true;
      event.preventDefault();
      event.stopPropagation();
      return false;
    })
  }

  if (!_.isUndefined($location.search().id)) {
    showPosition($location.search().id)
  }

  var active_cluster;
  window.last_level_cluster = function () {
    if (map.getZoom()==maxZoom) {
      angular.element(event.target.parentNode.parentNode.querySelector('.marker-window')).addClass('show');
    }
    return false;
  }

  window.stop = function (event) {
    if (map.getZoom()==maxZoom) {
      event.preventDefault();
      event.stopPropagation();
      return 0;
    }
  }

  var markerDescription = function (el) {
    return Data.trade_types_group[el[4]].plur+" "+el[5]+Data.dimensions_group[el[6]].title+", "+el[7]+Data.currency_group[el[8]].title+"/"+Data.dimensions_group[el[6]].title
  }

  var markerTitle = function (el) {
    return Data.options[el[3]].title_locale;
  }

  $scope.$watch(function () {
    return Search.markers
  }, function () {
    if (Search.markers) {
      if ($scope.markers)
        $scope.markers.clearLayers()
      
      $scope.markers = new L.MarkerClusterGroup({
        iconCreateFunction: function(cluster) {
          var positions = "";

          if (map.getZoom()==maxZoom) {
            _.each(cluster._markers, function (marker) {
              positions +=    '<div onclick="window.showPosition('+marker.options.data[0]+'); stop(event)" class="marker-window__item">'
                              + '<i class="marker-window__star flaticon-mark1 active"></i>'
                              + '<span class="">'+markerTitle(marker.options.data)+', '+markerDescription(marker.options.data)+'</span>'
                            + '</div>';
            })
          }

          return L.divIcon({
            // show the number of markers in the cluster on the icon.
            'marker-symbol': cluster.getChildCount(),
            html:  "<div class='marker-window' onclick='stop(event);'>"
                      + positions
                 + "</div>"
                 + "<div onclick='last_level_cluster();stop(event);' class='marker-label cluster cluster__"+cluster_name(cluster.getChildCount())+"'>"
                      + "<div class='marker-label__body'>"+cluster.getChildCount()+" "+pluralize(cluster.getChildCount(), gon.translation.position.plur)+"</div>"
                 + "</div>"
          });
        }
      });

      _.each(Search.markers, function (el) {
        var marker = L.marker([el[1], el[2]], {
            data: el,
            icon: L.divIcon({
              html: "<div onclick='window.showPosition("+el[0]+")' class='marker-label'>"
                      + "<div class='marker-label__head'>"+markerDescription(el)+"</div>"
                      + "<div class='marker-label__body'>"+markerTitle(el)+"</div>"
                  + "</div>"
            })
        });

        // marker.addTo(map);
        $scope.markers.addLayer(marker);
      })
      map.addLayer($scope.markers);
      if (Search.bound) {
          map.fitBounds($scope.markers.getBounds());
      } else {
        map.setView([52.93539665862318, 36.3427734375], 5);
      }
    }
  }, true)


  window.map = Search.map = L.mapbox.map('map', 'storuky.bb38e7c8', {
              zoomControl: false,
              minZoom: 2,
              maxZoom: maxZoom,
              maxBounds: [[90,-220],[-90, 220]],
              // attributionControl: false
            })
      .setView([52.93539665862318, 36.3427734375], 5);

  Search.layer = L.mapbox.featureLayer().addTo(map);
  $scope.mapReady = true;



  // map.locate();
  map.on('locationfound', function(e) {
      map.fitBounds(e.bounds);
      map.setZoom(12);
  });

  function cluster_name(count) {
    var name = "";
    if (count < 5) {
      name = 'small';
    } else if (count < 15) {
      name = 'medium';
    } else if (count < 25) {
      name = 'large';
    } else {
      name = 'extra';
    }
    return name;
  }

  var dragFade = angular.element(document.querySelectorAll('.search, .side-bar, .search__popup'));
  
  map.on('drag', function () {
    dragFade.css({opacity: 0.5});
  });

  map.on('dragend', function () {
    dragFade.css({opacity: 1});
  })

  map.on('locationerror', function() {
    $scope.mapReady = true;
    $scope.$apply();
  });
}])