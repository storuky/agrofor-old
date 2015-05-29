app.run(['$rootScope', 'Offer', 'Message', 'User', '$timeout', function($rootScope, Offer, Message, User, $timeout) {
  if (gon.user.private_pub) init();
  function init () {
    PrivatePub.sign(gon.user.private_pub);

    PrivatePub.subscribe('/stream/'+User.data.id, function(data) {
      switch (data.type) {
        case 'new_offer':
          newOfferFromStream(data);
          break;
        case 'new_correspondence':
          newCorrespondenceFromStream(data);
          break;
        case 'new_message':
          newMessageFromStream(data);
          break;
        case 'destroy_offer':
          destroyOfferFromStream(data);
          break;
      }
      $rootScope.$apply();
    });

    function newOfferFromStream (data) {
      Offer.new_offers_count = Offer.new_offers_count || 0;
      Offer.new_offers_count += 1;
      Offer.sendCallback(data.offer, data.position_id)
    }

    function newCorrespondenceFromStream (data) {
      if (Message.correspondences) {
        var correspondence = _.find(Message.correspondences, function(conv){
          return conv.id == data.correspondence.id
        })

        if (!correspondence && Message.correspondence_type==data.correspondence.correspondence_type) {
          Message.correspondences.unshift(data.correspondence);
        }
      }
    }
    function newMessageFromStream (data) {
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
    }

    function destroyOfferFromStream (data) {
      Offer.new_offers_count -= 1;
      Offer.withdrawCallback(data.offer_id, data.position_id, 'offers');
    }


    // PrivatePub.subscribe('/connection_closed', function() {
    //   $timeout(function () {
    //     init();
    //     if (Message.active_correspondence) {
    //       Message.active_correspondence.updated_at = new Date();
    //     }
    //     $rootScope.$apply();
    //   }, 1000)
    // })
  }

}])