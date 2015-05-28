app.directive('fileread', ['$parse', function ($parse) {
    return {
        scope: {
            fileread: "="
        },
        restrict: 'A',
        link: function($scope, element, attrs) {  
            element.bind('change', function(){
                $scope.fileread = element[0].files;
                console.log("=======")
                $scope.$apply()
                console.log("=======")
            });
        }
    };
}]);