app.directive('message', ['Message', 'Data', function(Message, Data){
  // Runs during compile
  return {
    // name: '',
    // priority: 1,
    // terminal: true,
    scope: {}, // {} = isolate, true = child, false/undefined = no change
    // controller: function($scope, $element, $attrs, $transclude) {},
    // require: 'ngModel', // Array = multiple requires, ? = optional, ^ = check parent elements
    restrict: 'E', // E = Element, A = Attribute, C = Class, M = Comment
    template: function (el, attrs) {
      return document.getElementById('message_'+attrs.type).innerHTML
    },
    // templateUrl: '',
    replace: true,
    // transclude: true,
    // compile: function(tElement, tAttrs, function transclude(function(scope, cloneLinkingFn){ return function linking(scope, elm, attrs){}})),
    link: function($scope, iElm, attrs, controller) {
      $scope.message = $scope.$parent.message;
      $scope.Data = Data;
      if (Message.position) {
        if (attrs.type == 'complete'){
          $scope.deal_plur2 = gon.translation.message.deal_plur2;
        }

        if (attrs.type == 'new_offer'){
          $scope.deal_plur1 = gon.translation.message.deal_plur1;
        }

        if ($scope.message.sender_id == Message.position.user_id)
          $scope.offer = Message.position
        else
          $scope.offer = Message.offer
      }
    }
  };
}]);