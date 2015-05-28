app.service('Data', ['$rootScope', function($rootScope){
  var Data = this;
  _.extend(Data, gon.data);
  Data.options = _.indexBy(_.flatten(_.map(_.flatten(gon.data.categories), function(category){return category.options})), "id");
  Data.currency_group = _.indexBy(gon.data.currency, "id");
  Data.dimensions_group = _.indexBy(gon.data.dimensions, "id");
  Data.trade_types_group = _.indexBy(gon.data.trade_types, "id");
  Data.search_view_group = _.indexBy(gon.data.search_view, "id");
  Data.statuses_group = _.indexBy(gon.data.statuses, "id");
  Data.positions_offers_group = _.indexBy(gon.data.positions_offers, "id");
  Data.trade_types_name = {
    1: "buy",
    2: "sell"
  }

  Data.reputation_type_group = _.indexBy(Data.reputation_type, "id");
}])