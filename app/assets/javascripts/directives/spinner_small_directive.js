app.directive('spinnerSmall', [function(){
  return {
    restrict: "E",
    template:   '<svg class="spinner" width="25px" height="25px" viewBox="0 0 66 66" xmlns="http://www.w3.org/2000/svg">'
                + '<circle class="path" fill="none" stroke-width="6" stroke-linecap="round" cx="33" cy="33" r="30"></circle>'
              + '</svg>'
  };
}]);