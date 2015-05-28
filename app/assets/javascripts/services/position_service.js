app.service('Position', ['$resource', '$location', '$http', 'Data', 'Message', 'Action', function($resource, $location, $http, Data, Message, Action) {
  var Position = this;

  var resource = $resource('/ajax/positions/:id.json', {id: '@id'}, {
    create: {method: "POST", headers: {'Content-Type': undefined}},
    update: {method: "PUT", headers: {'Content-Type': undefined}}
  });

  Position.get = resource.get;
  Position.query = resource.query;
  Position.create = resource.create;
  Position.update = resource.update;
  Position.delete = resource.delete;

  Position.goToEdit = function (id, $event) {
    $location.url('/positions/'+id+'/edit');
    $event.stopPropagation();
    $event.preventDefault();
    return false;
  }

  Position.goTo = function (id, $event) {
    $location.url('/positions/'+id);
    $event.stopPropagation();
    $event.preventDefault();
    return false;
  }

  Position.goToChat = function (position_id, offer_id, $event) {
    $http.get('/ajax/correspondences/find_correspondence?offer_id='+offer_id+'&position_id='+position_id)
      .success(function (res) {
        $location.url('/correspondences?type=positions&id='+res.id);
      })
    $event.stopPropagation();
    $event.preventDefault();
    return false;
  }

  Position.withdraw = function (position_id, offer_id) {
    Action.confirm({
      main: "Вы дейстивтельно хотите отменить сделку?",
      description: "В любой момент Вы сможете перезаключить сделку с данным пользователем."
    }, function () {
      $http({method: "DELETE", url: '/ajax/positions/withdraw', params: {position_id: position_id, offer_id: offer_id}})
        .success(function (res) {
          if (Position.positions) {
            Position.positions = _.reject(Position.positions, function (position) {
              return !position.length
            })
          }
          Data.statuses = res.statuses;
        })
    })
  }

  Position.agree = function (position_id, offer_id) {
    Action.confirm({
      main: "Вы обсудили все условия сделки в чате?",
      description: "Обращаем ваше внимание, что подтвержденные сделки отменить нельзя."
    }, function () {
      $http({method: 'PUT', url: '/ajax/positions/agree', params: {position_id: position_id, offer_id: offer_id}})
        .success(function (res) {
          Data.statuses = res.statuses;
        })
    })
  }

  Position.complete = function (position_id, offer_id) {
    Action.confirm({
      main: "Вы дейстивтельно подтверждаете получение товара?",
      description: "После подтверждения, Вы сможете оставить отзыв данному пользователю. Просим Вас отнестись со всей ответственностью к данному действию. От репутации пользователя зависит уровень доверия к нему."
    }, function () {
      $http({method: 'PUT', url: '/ajax/positions/complete', params: {position_id: position_id, offer_id: offer_id}})
        .success(function (res) {
          Data.statuses = res.statuses;
        })
    })
  }

  Position.reject = function (position_id, offer_id) {
    Action.confirm({
      main: "Вы действительно хотите отказаться от сделки?",
      description: "Предложение будет отклонено, о чем появится соответствующее сообщение в чате."
    }, function () {
      $http({method: "DELETE", url: '/ajax/positions/reject', params: {position_id: position_id, offer_id: offer_id}})
        .success(function (res) {
          Data.statuses = res.statuses;
        })
    })
  }


  Position.buildInfo = function (position) {
    if (position) {
      var weight = position.weight,
          weight_dimension = Data.dimensions_group[position.weight_dimension_id].title,
          weight_min = position.weight_min,
          price = position.price,
          currency = Data.currency_group[position.currency_id].title

      return [weight + ' ' + weight_dimension, 'мин. ' + weight_min + ' ' + weight_dimension, price + ' ' + currency + '/' + weight_dimension].join(', ')
    }
  }
}])