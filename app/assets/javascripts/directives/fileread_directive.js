app.directive('fileread', ['$parse', function ($parse) {
    return {
        scope: {
            fileread: "="
        },
        restrict: 'A',
        link: function(scope, element, attrs) {  
            element.bind('change', function(){
                scope.$apply(function(){
                    scope.fileread = element[0].files;
                });
            });
        }
    };
}]);