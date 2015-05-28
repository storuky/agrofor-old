app.filter('to_trusted', ['$sce', function($sce){
    return function(text, is_html) {
      var txt = is_html ? text : window.htmlToPlaintext(text);
      return $sce.trustAsHtml(txt);
    };
}]);