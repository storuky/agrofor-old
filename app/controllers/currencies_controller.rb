class CurrenciesController < ApplicationController
  def current_rates
    name = current_user.currency.name rescue session[:currency]["name"]

    render json: {rate: Currency.get_rates(name)}
  end
end
