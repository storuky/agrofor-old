class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception

  layout :false

  def index
    if current_user && current_user.locale
      I18n.locale = current_user.locale
    else
      geo = Geocoder.search(request.remote_ip).first
      if ["RU", "BY", "UA", "KZ"].include? I18nData.country_code(geo.country || "")
        I18n.locale = :ru
      else
        I18n.locale = :en
      end
    end
    # expires_in 5.minutes
    if current_user
      gon.user = current_user.info
      gon.user[:new_messages_count] = current_user.new_messages_count
      gon.user[:new_offers_count] = current_user.new_offers_count
      gon.user[:private_pub] = authorize_private_channel("/stream/#{current_user.id}")
    else
      gon.user = {
        :avatar => {:url => "/default-avatar.png"},
        :favorite_ids => [],
        :new_messages_count => 0,
        :new_offers_count => 0,
        :currency => Currency.find(1).as_json(:methods => :title),
        :phone => []
      }
    end
    
    gon.data = {
      locales: [{id: "ru", title: "Русский"},{id: "en", title: "English"}],
      categories: Category.with_options.each_slice( (Category.with_options.size/4.0).round ).to_a,
      trade_types: Position.trade_types,
      statuses: Position.statuses,
      reputation_type: [{id: 'positive', title: I18n.t("position.dictionary.reputation_type.positive"), color: "green"}, {id: 'negative', title: I18n.t("position.dictionary.reputation_type.negative"), color: "red"}],
      currency: Currency.all.as_json(:only => [:id], methods: [:title]),
      trade_types_association: Position::TRADE_TYPES_ASOCIATION,
      dimensions: WeightDimension.all.as_json(only: [:id], methods: [:title]),
      search_view: [{id: 1, title: I18n.t("search.dictionary.by_map"), value: "map"}, {id: 2, title: I18n.t("search.dictionary.by_list"), value: "list"}],
      positions_offers: [{id: "positions", title: I18n.t("position.dictionary.positions")}, {id: "offers", title: I18n.t("position.dictionary.offers")}]
    }

    gon.translation = {
      position: {
        plur: I18n.t('position.plur')
      },
      confirm: I18n.t('confirm'),
      category: {
        plur: I18n.t('category.plur')
      },
      message: {
        deal_plur1: I18n.t('message.position.plur1'),
        deal_plur2: I18n.t('message.position.plur2')
      },
      user: I18n.t('user'),
      dictionary: I18n.t('dictionary')
    }


    # if current_user
      # Digest::SHA1.hexdigest([Time.now, rand].join)
    # end

    render file: "layouts/application"
  end

  private
    def authorize_private_channel channel
      PrivatePub.subscription(:channel => channel).as_json
    end

    def init_chanels

    end

    def broadcast(channel, &block)  
      message = {:channel => channel, :data => '---'}  
      uri = URI.parse("http://localhost:3000/faye")  
      Net::HTTP.post_form(uri, :message => message.to_json)  
    end  
end
