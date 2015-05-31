app.service('User', ['$resource', '$http', function($resource, $http) {
  var User = this;

  User.data = gon.user;

  var resource = $resource('/ajax/profile')
  
  User.save = function () {
    resource.save(User.data, function () {
      // body...
    });
  }

  User.isFavorite = function (id) {
    return User.data.favorite_ids.indexOf(id)!=-1
  }
}])