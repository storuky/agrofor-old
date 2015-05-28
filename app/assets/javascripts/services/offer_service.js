app.service('Offer', ['Position', '$resource', '$location', 'Data', '$http', 'Action', function(Position, $resource, $location, Data, $http, Action) {

  var Offer = this;
  
  var resource = $resource('/ajax/offers', {}, {
    send: {method: "POST"}
  })

  Offer.query = resource.query;
  Offer.get = resource.get;

  Offer.send = function (position_id, offer_id) {
    resource.send({offer_id: offer_id, position_id: position_id}, function (res) {
      $location.url('/correspondences?type=positions&id='+res.correspondence_id);
    })
  }

  Offer.withdraw = function (offer_id, position_id) {
    Action.confirm({
      main: "Вы действительно хотите отозвать предложение?",
      description: "В любой момент вы сможете отправить его заново."
    }, function () {
      resource.delete({offer_id: offer_id, position_id: position_id}, function (res) {
        Offer.withdrawCallback(position_id, offer_id, 'positions')

        Position.positions = _.reject(Position.positions, function (position) {
          return !position.positions.length
        })
        Data.offers_statuses = res.offers_statuses
      })
    })
  }

  Offer.sendCallback = function (offer, position_id) {
    if (Position.positions) {
      var position_index;
      _.find(Position.positions, function (position, num) {
        position_index = num;
        return position.id == position_id
      })

      var offer = offer;
      Position.positions[position_index].offers.unshift(offer)
    }
  }

  Offer.withdrawCallback = function (position_id, offer_id, collection) {
    if (Position.positions) {
      var position_index, offer_index;
      _.find(Position.positions, function (position, num) {
        position_index = num;
        return position.id == position_id
      })
      if (Position.positions[position_index]) {
        _.find(Position.positions[position_index][collection], function (offer, num) {
          offer_index = num;
          return offer.id == offer_id
        })
        Position.positions[position_index][collection].splice(offer_index, 1)
      }
    }
  }

  Offer.resetCounter = function () {
    $http({method: "DELETE", url: "/ajax/offers/reset_counter"})
      .success(function () {
        Offer.new_offers_count = 0;
      })
  }
}])