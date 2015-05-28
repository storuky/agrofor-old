app.run(['$rootScope', 'Offer', 'Message', 'User', '$timeout', function($rootScope, Offer, Message, User, $timeout) {
  // init();
  function init () {
    window.dispatcher = new WebSocketRails(window.location.hostname + ":3333/websocket");
    dispatcher.bind('positions.new_offer', function(data) {
      Offer.new_offers_count = Offer.new_offers_count || 0;
      Offer.new_offers_count += 1;
      Offer.sendCallback(data.offer, data.position_id)

      $rootScope.$apply();
    });

    dispatcher.bind('correspondences.create', function (data) {
      if (Message.correspondences) {
        var correspondence = _.find(Message.correspondences, function(conv){
          return conv.id == data.correspondence.id
        })

        if (!correspondence && Message.correspondence_type==data.correspondence.correspondence_type) {
          Message.correspondences.unshift(data.correspondence);
        }
      }
      $rootScope.$apply();
    })

    dispatcher.bind('positions.destroy_offer', function(data) {
      Offer.new_offers_count -= 1;
      Offer.withdrawCallback(data.offer_id, data.position_id, 'offers');
      $rootScope.$apply();
    })

    dispatcher.bind('correspondences.new_message', function (data) {
      if (Message.active_correspondence) {
        if (Message.active_correspondence.id!=data.message.correspondence_id) {
          Message.update(data)
        } else {
          if (data.message.sender_id!=User.data.id)
            Message.resetCount();
          Message.sendCallback(data.message);
          Message.active_correspondence.status = data.status;
        }
      } else {
        Message.update(data)
      }
      $rootScope.$apply();
    })

    dispatcher.bind('connection_closed', function() {
      $timeout(function () {
        init();
        if (Message.active_correspondence) {
          Message.active_correspondence.updated_at = new Date();
        }
        $rootScope.$apply();
      }, 1000)
    })
  }

}])