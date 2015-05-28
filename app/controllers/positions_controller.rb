class PositionsController < ApplicationController
  before_action :set_position, only: [:edit, :update, :destroy]

  respond_to :html

  def index
    respond_to do |format|
      format.html
      format.json do
        if params[:status] == 'opened'
          positions = current_user.positions.where(status: params[:status]).includes(:offers).as_json(:include => :offers) rescue []
        else
          positions = current_user.positions.where(status: params[:status]).as_json(:methods => [:deal_with]) rescue []
        end

        statuses = Position.status(current_user.id) rescue Position.status(0)
        render json: {
          positions: positions,
          statuses: statuses
        }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.json { render json: @position.as_json(:include => [:photos]) }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json do
        position = Position.find(params[:id])
        suitable_list_ids = Position.find_suitable([position], current_user.id) rescue []
        currency = current_user.currency rescue Currency.first
        suitable_list = Position.where(id: suitable_list_ids)
        render json: {position_info: position.with_user(currency), suitable_list: suitable_list}
      end
    end
  end

  def form
    templates = current_user.templates.map{|tmpl| {id: tmpl.id, title: tmpl.template_name}} rescue []
    respond_to do |format|
      format.html
      format.json do
        render json: {
          templates: templates
        }
      end
    end
  end

  def create
    if current_user
      wait_for = DateTime.now.to_i - current_user.positions.last.created_at.to_datetime.to_i rescue 61
      if wait_for > 60
        @position = current_user.positions.new(position_params)
        if photos = params.permit(:photos => [])[:photos]
          photos = photos.map do |photo|
            ph = Photo.new
            ph.photo = photo
            ph
          end
          @position.photos = photos
        end
        if (@position.save)
          if params[:is_template]
            template_params = position_params.merge(template_name: params[:template_name])
            current_user.templates << Template.new(template_params)
          end
          result = { msg: I18n.t('position.notice.created'), position_id: @position.id }
          render json: result
        else
          render json: {errors: @position.errors}, :status => 500
        end
      else
        render json: {msg: I18n.t("position.notice.timeout")}, status: 500
      end
    else
      render json: {msg: I18n.t("user.notice.not_auth")}, status: 500
    end
  end

  def update
    if @position && !@position.is_offer
      @position.update(position_params)
      if photos = params.permit(:photos => [])[:photos]
        photos = photos.map do |photo|
          ph = Photo.new
          ph.photo = photo
          ph
        end
        @position.photos = photos
        @position.save
      end
      render json: {msg: I18n.t('position.notice.updated')}
    else
      render json: {errors: @position.errors}, status: 500
    end
  end

  def by_user
    render json: {positions: Position.where(user_id: params[:user_id])}
  end

  def delete_template
    current_user.templates.find(params[:id]).destroy
    render json: {}
  end

  # def destroy
  #   @position.destroy
  #   render json: {msg: I18n.t('position_deleted'), type: "success"}
  # end

  def archive
    position = current_user.positions.where(id: params[:id]).first
    if position
      position.move_to_archive!

      if position.offers.count!=0 || position.positions.count!=0
        correspondences = Correspondence.where('position_id = ? OR offer_id = ?', position.id)
        correspondences.each do |correspondence|
          correspondence.messages.create(message_type: "withdraw", user_id: current_user.id, correspondence_id: correspondence.id)
        end
        position.offers = []
        position.positions = []
      end

      if position.save
        render json: {msg: I18n.t('position.notice.closed')}
      else
        render json: {msg: I18n.t('position.notice.saved.error')}, status: 500
      end
    else
      render json: {msg: I18n.t('position.notice.not_found')}, status: 500
    end
  end

  def restore
    position = current_user.positions.where(id: params[:id]).first
    if position && position.archive?
      position.open!
      render json: {msg: I18n.t('position.notice.restored'), type: "success"}
    else
      render json: {msg: I18n.t('position.notice.not_found'), type: "error"}, status: 500
    end
  end

  def reject
    correspondence = current_user.correspondences.between_positions(params[:position_id], params[:offer_id])
    position_agree = correspondence.position_agree? && correspondence.offerer_id==current_user.id
    position_not_agree = correspondence.new_offer? && correspondence.offerer_id!=current_user.id
    if position_agree || position_not_agree
      offer, position = Position.position_and_offer [params[:position_id], params[:offer_id]], correspondence.offerer_id
      offer.update(deal_with_id: nil)
      position.update(deal_with_id: nil)
      position.offers.delete(offer)
      offer.positions.delete(position)
      
      recipient_id = position_agree ? position.user_id : offer.user_id
      correspondence.stop!
      correspondence.messages.create(message_type: "reject", sender_id: current_user.id, recipient_id: recipient_id, correspondence_id: correspondence.id)
      render json: {msg: I18n.t('position.notice.rejected'), statuses: Position.status(current_user.id)}
    else
      render json: {msg: I18n.t('user.notice.not_permit')}, status: 500
    end
  end

  def agree
    correspondence = current_user.correspondences.between_positions(params[:position_id], params[:offer_id])
    position_agree = correspondence.position_agree? && correspondence.offerer_id==current_user.id
    position_not_agree = correspondence.new_offer? && correspondence.offerer_id!=current_user.id

    if position_agree || position_not_agree
      offer, position = Position.position_and_offer [params[:position_id], params[:offer_id]], correspondence.offerer_id
      recipient_id = position_agree ? position.user_id : offer.user_id
      
      if position_agree
        correspondence.run_offer_agree!
        offer.start_process!
        position.start_process!
      else
        correspondences_for_close = current_user.correspondences.where('(position_id = ? OR offer_id = ?) AND (correspondences.id != ?)', position.id, position.id, correspondence.id)
        correspondences_for_close.each do |conv|
          unless conv.stopped?
            position, offer = Position.position_and_offer [conv.position_id, conv.offer_id], current_user.id
            conv.messages.create(message_type: "withdraw", sender_id: current_user.id, recipient_id: offer.user_id, correspondence_id: correspondence.id)
            conv.stop!
            conv.position.offers.delete(conv.position)
            conv.offer.positions.delete(conv.offer)
            conv.position.update(deal_with_id: nil)
            conv.offer.update(deal_with_id: nil)
          end
        end
        offer.update(is_offer: false, deal_with_id: position.id)
        position.update(is_offer: false, deal_with_id: offer.id)
        correspondence.run_position_agree!
      end

      correspondence.messages.create(message_type: "agree", sender_id: current_user.id, recipient_id: recipient_id, correspondence_id: correspondence.id)
      render json: {msg: I18n.t('position.notice.agree'), type: "success", statuses: Position.status(current_user.id)}
    else
      render json: {msg: I18n.t('user.notice.not_permit'), type: "error"}, status: 500
    end
  end

  def complete
    correspondence = current_user.correspondences.between_positions(params[:position_id], params[:offer_id])
    position, offer = Position.position_and_offer [params[:position_id], params[:offer_id]], current_user.id

    position_agree = correspondence.offer_agree? && position.trade_type == 2
    position_complete = correspondence.position_complete? && position.trade_type == 1

    if position_agree || position_complete
      recipient_id = offer.user_id
      
      if position_agree
        correspondence.run_position_complete!
        correspondence.messages.create(message_type: "complete", sender_id: current_user.id, recipient_id: recipient_id, correspondence_id: correspondence.id)
        render json: {msg: I18n.t('position.notice.completed'), type: "success", statuses: Position.status(current_user.id)}
      else
        correspondence.run_offer_complete!
        offer.complete!
        position.complete!
        correspondence.messages.create(message_type: "complete", sender_id: current_user.id, recipient_id: recipient_id, correspondence_id: correspondence.id)
        render json: {msg: I18n.t('offer.notice.completed'), type: "success", statuses: Position.status(current_user.id)}
      end

    else
      render json: {msg: I18n.t('action_not_permit'), type: "error"}, status: 500
    end
  end

  def withdraw
    correspondence = current_user.correspondences.between_positions(params[:position_id], params[:offer_id])

    if correspondence.new_offer? && correspondence.offerer_id==current_user.id
      offer, position = Position.position_and_offer [params[:position_id], params[:offer_id]], correspondence.offerer_id
      
      position.offers.delete(offer)
      offer.positions.delete(position)
      offer.update(deal_with_id: nil)
      position.update(deal_with_id: nil)
      correspondence.stop!
      correspondence.messages.create(message_type: "withdraw", sender_id: current_user.id, recipient_id: position.user_id, correspondence_id: correspondence.id)
      render json: {msg: I18n.t('offer.notice.deleted'), type: "success", statuses: Position.status(current_user.id)}
    else
      render json: {msg: I18n.t('action_not_permit'), type: "error"}, status: 500
    end
  end

  def toggle_favorite
    if current_user
      if current_user.favorite_ids.include? params[:id].to_i
        current_user.favorites.delete(params[:id].to_i)
      else
        current_user.favorites << Position.find(params[:id])
      end
      render json: current_user.favorite_ids
    else
      render json: {msg: I18n.t("not_auth"), type: "error"}, status: 500
    end
  end

  def delete_photo
    photo = Photo.find(params[:id])
    if photo.position.user.id == current_user.id
      Photo.destroy(params[:id])
      render json: photo.position.photos
    else
      render json: {msg: I18n.t("file_remove_error"), type: "error"}, status: 500
    end
  end

  def template
    render json: current_user.templates.find(params[:id]).as_json(:except => [:template_name])
  end

  private
    def set_position
      @position = current_user.positions.find(params[:id])
    end

    def position_params
      params.permit(:option_id, :option_title, :title, :trade_type, :price, :price_discount, :weight, :weight_dimension_id, :currency_id, :weight_min, :description, :address, :lat, :lng, :city)
    end
end
