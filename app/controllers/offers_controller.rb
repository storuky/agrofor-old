class OffersController < ApplicationController
  def reset_counter
    current_user.new_offers_count = 0;
    current_user.save
    render json: {}
  end

  def show
    positions = current_user.positions.where(status: params[:status], is_offer: true).as_json(:include => [:positions]) rescue []
    render json: {
      positions: positions
    }
  end

  def destroy
    position = current_user.positions.where(id: params[:position_id]).first
    offer = position.positions.where(id: params[:offer_id]).first
    correspondence = Correspondence.between_positions(position.id, offer.id)

    if correspondence.offer_agree?
      render json: {
        msg: I18n.t("offer.notice.withdraw_error"),
      }, status: 500
    else
      correspondence.stop!

      position.positions.delete(offer)
      offer.offers.delete(position)

      message = correspondence.messages.create(message_type: "withdraw", sender_id: current_user.id, recipient_id: offer.user_id, correspondence_id: correspondence.id)

      render json: {
        msg: I18n.t("offer.notice.deleted"),
        offers_statuses: Offer.status(current_user.id),
        message: message
      }
    end
  end

  def create
    position = Position.find(params[:position_id])
    offer = Position.find(params[:offer_id])
    unless position.deal_with_id
      if position.check_suitable(offer)
        correspondence = Correspondence.between_positions(position.id, offer.id)
        
        if position.offers.where(id: offer.id).first && !correspondence.stopped?
          render json: { msg: I18n.t("offer.notice.send_earlier")}, status: 500
        else
          correspondence ||= Correspondence.create_between_positions(position, offer)
          correspondence.run_new_offer! if correspondence.stopped?
          correspondence.update(offerer_id: current_user.id)
          
          if correspondence.new_offer?
            offer.positions << position
            position.offers << offer
            
            correspondence.messages.create(message_type: "new_offer", sender_id: current_user.id, recipient_id: position.user_id, correspondence_id: correspondence.id)

            render json: {
              msg: I18n.t("offer.notice.created"),
              offer: offer,
              position_id: position.id,
              correspondence_id: correspondence.id,
              correspondence: correspondence
            }
          else
            render json: {msg: I18n.t("offer.notice.double")}, status: 500
          end
        end
      else
        render json: { msg: I18n.t("offer.notice.unsuitable")}, status: 500
      end
    else
        render json: { msg: I18n.t("position.notice.already_in_process")}, status: 500
    end
  end
end
