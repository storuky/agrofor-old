class Position < ActiveRecord::Base
  require 'convert'
  include AASM

  aasm :column => :status do
    state :opened, :initial => true
    state :in_process
    state :completed
    state :archive

    event :start_process do
      transitions :to => :in_process, :from => [:opened]
    end

    event :complete do
      transitions :to => :completed, :from => [:in_process]
    end

    event :move_to_archive do
      transitions :to => :archive, :from => [:opened]
    end

    event :open do
      transitions :to => :opened, :from => [:archive]
    end
  end

  
  before_save :set_etalon
  before_save :set_index_field

  has_many :photos
  has_one :reputation
  

  belongs_to :user
  belongs_to :option

  belongs_to :weight_dimension
  belongs_to :currency

  has_and_belongs_to_many :favorites, class_name: 'User'

  has_and_belongs_to_many :offers, association_foreign_key: :incoming_offer_id, class_name: 'Position', after_add: :create_offer, after_remove: :destroy_offer
  has_and_belongs_to_many :positions, association_foreign_key: :outcoming_position_id, class_name: 'Position', after_add: :create_position_for_offer, after_remove: :destroy_position_for_offer

  belongs_to :position, foreign_key: :position_id, class_name: 'Position'
  
  has_and_belongs_to_many :correspondences


  # has_and_belongs_to_many :offers, foreign_key: 'offer_id', class_name: 'Position'
  # belongs_to :position, foreign_key: 'position_id', class_name: 'Position' 
  
  def category_translate
    current_translations["category"]
  end

  def self.statuses
    Position.aasm.states.map do |state|
      {id: state.name, title: I18n.t('position.status.'+state.name.to_s)}
    end
  end

  def self.statuses_group
    Position.statuses.index_by{ |t| t[:id]}
  end

  def self.trade_types
    [
      { title: I18n.t('position.dictionary.buy'), id: 1, plur: I18n.t('position.dictionary.buy_plur') },
      { title: I18n.t('position.dictionary.sell'), id: 2, plur: I18n.t('position.dictionary.sell_plur') }
    ]
  end

  def trade_types_group
    Position.trade_types.index_by {|t| t[:id]}
  end

  def self.trade_types_ids
    Position.trade_types.map{ |t| t[:id] }
  end

  def self.dimensions_ids
    WeightDimension.all.map(&:id)
  end

  TRADE_TYPES_ASOCIATION = {
    1 => 2,
    2 => 1
  }

  DELIVERY_TYPES = [
    { id: 1, title: 'Нет' },
    { id: 2, title: 'Бесплатная доставка' },
    { id: 3, title: 'Платная доставка' }
  ]


  validates :trade_type, inclusion: { in: Position.trade_types_ids }
  validates :title, presence: true, length: { maximum: 50 }
  validates :option_id, numericality: true
  validates :address, presence: true
  validates :weight, numericality: { greater_than: 0 }
  validates :weight_dimension_id, inclusion: { in: Position.dimensions_ids }
  validate :less_then_weight
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :price_discount, :allow_blank => true, numericality: { greater_than_or_equal_to: 0 }

  def self.markers
    pluck(:id, :lat, :lng, :option_id, :trade_type, :weight, :weight_dimension_id, :price, :currency_id)
  end

  def marker
    [id, lat, lng, option_id, trade_type, weight, weight_dimension_id, price, currency_id]
  end

  def as_json params={}
    json = super(params)
    if params[:user]
        json["offers"] = json["offers"].select do |offer|
          offer["user_id"]==params[:user].id
        end
    end

    json
  end

  def with_user currency = nil
    query = {
              :include => {
                :user => {
                  only: [:name, :id, :avatar],
                  methods: [:negative_count, :positive_count]
                },
                :photos => {},
                :reputation => {}
              },
              :methods => [:deal_with]
            }
    json = self.as_json query
    if currency
      rate = self.currency.get_rate(currency.name)
      if rate != 1
        json["price_in_currency"] = (self.price * rate).round(2)
      end
    end
    json
  end

  def self.find_suitable positions, user_id = nil
    offers = []
    positions.each do |position|
      dimension = position.weight_dimension_id

      trade_type = TRADE_TYPES_ASOCIATION[position.trade_type]
      weight_etalon = (position.weight_min.weight(dimension)..INF)
      option_id = position.option_id
      weight_min_etalon = (0.0..position.weight.weight(dimension))


      params = {
        trade_type: trade_type,
        option_id: option_id,
        weight_etalon: weight_etalon,
        weight_min_etalon: weight_min_etalon,
      }

      if user_id
        params[:user_id] = user_id
      end

      _offers = Position.where(deal_with_id: nil, id: Position.search_for_ids(:with => params, :per_page => 10000)).includes(:currency)
      _offers = _offers.select do |offer|
        price_etalon_in_currency = position.price_etalon / offer.currency.get_rate(position.currency.name)

        case position[:trade_type]
          when 1
            price_etalon_in_currency *= 1+offer.price_discount/100
            offer.price_etalon.between?(0.0, price_etalon_in_currency)
          when 2
            price_etalon_in_currency *= 1-offer.price_discount/100
            offer.price_etalon.between?(price_etalon_in_currency, INF)
        end
      end

      offers += _offers.as_json
    end
    offers.as_json.uniq.map{|offer| offer["id"]}
  end

  def self.find_by_params position, is_marker, user_id = nil
    dimension = position[:weight_dimension_id]
    currency = Currency.find(position[:currency_id]).name
    weight_from = position[:weight_from].weight(dimension) rescue 0.0
    weight_to = position[:weight_to].weight(dimension) rescue INF
    price_from = position[:price_from].price(dimension) rescue 0.0
    price_to = position[:price_to].price(dimension) rescue INF

    trade_type = TRADE_TYPES_ASOCIATION[position[:trade_type]]
    option_id = position[:option_id]
    weight_etalon = (weight_from..weight_to)

    params = {
      trade_type: trade_type,
      option_id: option_id,
      weight_etalon: weight_etalon
    }.delete_if { |k, v| v.blank? }

    position_ids = Position.search_for_ids(position[:query], :with => params, :per_page => 10000)
    positions = Position.where(deal_with_id: nil, id: position_ids)
    
    if position[:price_from] || position[:price_to]
      positions = positions.includes(:currency).select do |position|
        diff = position.currency.get_rate(currency)
        position.price_etalon.between?(price_from/diff, price_to/diff)
      end
    end
    
    positions.map{|position| position[:id]}
  end


  def check_suitable offer
    price_etalon_in_currency = self.price_etalon * self.currency.get_rate(offer.currency.name)

    is_tradetype = self.trade_type == TRADE_TYPES_ASOCIATION[offer.trade_type]
    is_user_id = self.user_id != offer.user_id
    is_option_id = self.option_id == offer.option_id 
    is_status = self.status == 'opened' && offer.status == 'opened'
    is_weight = self.weight_min.weight(self.weight_dimension_id) <= offer.weight.weight(offer.weight_dimension_id)

    is_price =  case self.trade_type
                  when 1
                    price_etalon_in_currency *= 1+self.price_discount/100
                    ap price_etalon_in_currency
                    offer.price_etalon.between?(0.0, price_etalon_in_currency)
                  when 2
                    price_etalon_in_currency *= 1-self.price_discount/100
                    ap price_etalon_in_currency
                    offer.price_etalon.between?(price_etalon_in_currency, INF)
                end

    # ap "#{is_tradetype} #{is_user_id} #{is_option_id} #{is_status} #{is_price} #{is_weight}"
    is_tradetype && is_user_id && is_option_id && is_status && is_price && is_weight
  end

  def self.status user_id
    Position.statuses_group.keys.map do |state|
      count = Position.where({status: state, user_id: user_id, is_offer: false}).count

      {
        title: I18n.t('position.status.'+state.to_s) + " (#{count})",
        id: state,
        value: state
      }
    end
  end

  def deal_with
    query = {
      :include => {
        :user => {
          only: [:name, :id, :avatar],
          methods: [:negative_count, :positive_count]
        },
        :reputation => {},
        :photos => {}
      }
    }
    Position.where(id: deal_with_id).as_json(query)
  end

  def self.position_and_offer positions, user_id
    first_position = Position.find(positions.first)
    last_position = Position.find(positions.last)

    if first_position.user_id == user_id
      position = first_position
      offer = last_position
    elsif last_position.user_id == user_id
      position = last_position
      offer = first_position
    else
      position, offer = nil, nil
    end

    [position, offer]
  end

  private
    def set_etalon
      self.price_etalon = price.price(weight_dimension_id)
      self.weight_etalon = weight.weight(weight_dimension_id)
      self.weight_min_etalon = weight_min.weight(weight_dimension_id)
    end

    def set_index_field
      temp = [self.title]
      [:en, :ru].each do |locale|
        temp << I18n.t('position.dictionary.trade_types', :locale => locale)[self.trade_type]
        temp << I18n.t('category.items.'+self.option.category.title, :locale => locale)
        temp << I18n.t('option.'+Option.find(self.option_id).title, :locale => locale)
      end
      self.index_field = temp.join(" ")
    end

    def less_then_weight
      errors.add(:weight_min) if self.weight_min.to_f > self.weight.to_f
    end

    def create_offer offer
      opponent = self.user
      WebsocketRails.users[opponent.id].send_message :new_offer, {position_id: self.id, offer: offer.as_json}, :namespace => :positions
      opponent.new_offers_count += 1
      opponent.save
    end

    def destroy_offer offer
      opponent = self.user
      WebsocketRails.users[opponent.id].send_message :destroy_offer, {position_id: self.id, offer_id: offer.id}, :namespace => :positions
      opponent.new_offers_count -= 1
      opponent.save
    end

    def create_position_for_offer position
      unless self.is_offer
        self.is_offer = true
        self.save
      end
    end

    def destroy_position_for_offer position
      if self.is_offer && self.positions.count == 0
        self.is_offer = false
        self.save
      end
    end

    def current_translations
      @translations ||= I18n.backend.send(:translations)
      @translations[I18n.locale].with_indifferent_access
    end

end
