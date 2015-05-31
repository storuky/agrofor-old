class Currency < ActiveRecord::Base
  require 'money'
  require 'money/bank/google_currency'

  has_many :positions

  CURRENCY = [
    {
      name: "RUB", title: "руб"
    },
    {
      name: "USD", title: "$"
    },
    {
      name: "EUR", title: "€"
    },
    {
      name: "GBP", title: "£"
    },
    {
      name: "JPY", title: "¥"
    },
    {
      name: "CAD", title: "CAD"
    },
    {
      name: "CNY", title: "CNY"
    },
    {
      name: "AUD", title: "AUD"
    },
    {
      name: "NZD", title: "NZD"
    },
  ]

  def title
    I18n.t('currency.'+self.name)
  end

  def self.get_rates name
    rates = Currency.all.map do |currency|
      {id: currency.id, rate: currency.get_rate(name)}
    end
    rates.index_by{|rate| rate[:id]}
  end

  def get_rate name
    if self.name == name
      1
    else
      symbol = self.name + name
      if $redisCurrency.exists(symbol)
        $redisCurrency.get(symbol).to_f
      else
        bank = Money::Bank::GoogleCurrency.new
        rate = bank.get_rate(self.name, name).to_f
        $redisCurrency.set(symbol, rate, ex: 60*60)
        $redisCurrency.set(name+self.name, 1.0/rate, ex: 60*60)
        rate
      end
    end
  end
end
