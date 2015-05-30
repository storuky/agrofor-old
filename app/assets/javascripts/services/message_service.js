app.service('Message', ['$http', '$timeout', 'User', function($http, $timeout, User) {
  var Message = this;

  Message.messages = [];
  Message.new_messages_count = gon.user.new_messages_count;
  Message.unreadable_count = {};

  Message.send = function () {
    if (Message.body) {
      var data = {
        body: Message.body,
        id: Message.active_correspondence.id
      }
      $http({method: "POST", data: data, url: "/ajax/correspondences/new_message"})
        .success(function (res) {
          Message.body = '';
          Message.scrollBottom()
          correspondence_file.value = '';
          Message.attach_title = undefined;
        })
    }
  }

  Message.sendCallback = function (message) {
    Message.messages.push(message);
    Message.scrollBottom()
  }

  Message.scrollBottom = function () {
    $timeout(function () {
      var element = document.querySelector('.correspondences__messages__items');
      if (element) {
        element.scrollTop = element.scrollHeight;
      }
    });
  }

  Message.resetCount = function () {
    var correspondence_id = Message.active_correspondence.id;
    $http({method: "get", url: "/ajax/correspondences/reset_count", params: {correspondence_id: correspondence_id}})
      .success(function (res) {
        if (Message.unreadable_count[correspondence_id]) {
          Message.new_messages_count -= Message.unreadable_count[correspondence_id];
          if (Message.new_messages_count<0) Message.new_messages_count = 0;
          Message.unreadable_count[correspondence_id] = 0;
        }
      })
  }

  Message.update = function (data) {
    if (User.data.id != data.message.sender_id) {
      Message.new_messages_count += 1;
      Message.count[data.message_for] += 1

      if (Message.unreadable_count[data.message.correspondence_id]) {
        Message.unreadable_count[data.message.correspondence_id] += 1;
      } else {
        Message.unreadable_count[data.message.correspondence_id] = 1;
      }
    }
  }
}])