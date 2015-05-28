app.controller('CorrespondencesCtrl', ['$scope', '$http', '$location', '$timeout', '$filter', 'Message', 'User', function($scope, $http, $location, $timeout, $filter, Message, User) {
  var types = {
    1: "positions",
    2: "users"
  }
  Message.correspondence_type = $location.search().type || 'positions';

  $scope.$watch(function () {
    return Message.correspondence_type
  }, function (type) {
    $http.get('/ajax/correspondences.json?correspondence_by='+type).success(function (res) {
      Message.correspondences = res.correspondences;
      Message.unreadable_count = res.unreadable_count;
      if (!_.isUndefined($location.search().id)) {
        Message.active_correspondence = findById(Message.correspondences, $location.search().id);
        if (!Message.active_correspondence) {
          Message.active_correspondence = $filter('orderBy')(Message.correspondences, 'updated_at', true)[0];
        }
      } else {
        Message.active_correspondence = $filter('orderBy')(Message.correspondences, 'updated_at', true)[0];;
      }
    });
  })

  $scope.$watch('file', function (file) {
    if (file!==true) {
      if (file && file.length) {
        $scope.fileInProgress = true;
        var formData = new FormData();
        formData.append('document', file[0]);
        formData.append('correspondence_id', Message.active_correspondence.id);
        $http({
          method: "POST",
          url: "/ajax/correspondences/upload",
          data: formData,
          headers: {
            "Content-Type": undefined
          }
        }).success(function (res) {
          $scope.fileInProgress = false;
          Message.attach_title = res.document.file_name;
        })
      }
    }
  })

  $scope.deleteFile = function () {
    $http({method: "DELETE", url: "/ajax/correspondences/file", params: {correspondence_id: Message.active_correspondence.id}})
      .success(function () {
        correspondence_file.value = '';
        Message.attach_title = undefined;
      })
  }

  $scope.$watch(function () {
    return Message.active_correspondence
  }, function (n, o) {
    var old = o ? o : {};
    if (n && n.id!=old.id) {
      $location.search({type: Message.correspondence_type, id: n.id});

      Message.messages = undefined;
      $scope.inProgress = true;
      $http.get('/ajax/correspondences/'+n.id+'?type='+Message.correspondence_type).success(function (res) {
        Message.messages = res.messages;
        Message.position = res.position;
        Message.offer = res.offer;
        Message.page = 1;
        Message.resetCount();
        Message.active_correspondence.status = res.correspondence.status;
        
        
        if (res.document) {
          Message.attach_title = res.document.file_name;
          $scope.file = true;
        }

        $scope.inProgress = false;
        $scope.topMessage = false;

        Message.scrollBottom()
      })
    }
  });

  document.querySelector('.correspondences__messages__items').onscroll = function (e) {  
    if (e.target.scrollTop<10 && !$scope.inProgress && !$scope.topMessage) {
      var scroll = document.querySelector('.correspondences__messages__items').scrollTop;
      $scope.inProgress = true;
      $http.get('/ajax/correspondences/messages_page?page='+(Message.page+1)+'&id='+Message.active_correspondence.id).success(function (res) {
        window.firstMsg = document.querySelector('.correspondences__messages__item');

        if (res.messages.length) {
          _.each(res.messages.reverse(), function (msg) {
            Message.messages.unshift(msg);
          })
          Message.page = parseInt(res.page);
          $timeout(function () {
            document.querySelector('.correspondences__messages__items').scrollTop = firstMsg.offsetTop-50;
          })
        } else {
          $scope.topMessage = true;
        }
        $scope.inProgress = false;
      })
    }
  }

  $scope.$on("$destroy", function(){
    Message.active_correspondence = undefined;
  });

  Message.active='all'

  angular.element(document.querySelector('textarea.correspondences__textarea')).bind('keydown', function (e) {
    if ((e.metaKey || e.ctrlKey) && e.keyCode == 13) {
      Message.send();
      $scope.$apply();
    }
  });

}])