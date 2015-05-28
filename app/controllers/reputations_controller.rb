class ReputationsController < ApplicationController
  def create
    if current_user.positions.where(id: params[:offer_id]).first
      position = Position.where(id: params[:position_id], status: 'completed', deal_with_id: params[:offer_id]).first
      unless position
        render json: {msg: I18n.t('position.notice.not_found')}, status: 500
      else
        unless position.reputation
          body_valid = params[:description].present?
          reputation_type_valid = params[:reputation_type].present? && I18n.t('position.dictionary.reputation_type').keys.include?(params[:reputation_type].to_sym)
          if !body_valid
            render json: {msg: I18n.t('position.notice.empty_reputation')}, status: 500 
          elsif !reputation_type_valid
            render json: {msg: I18n.t('position.notice.empty_reputation_type')}, status: 500 
          elsif
            position.reputation = Reputation.new(user_id: position.user_id, sender_id: current_user.id, position_id: position.id, description: params[:description], reputation_type: params[:reputation_type])
            render json: {reputation: position.reputation}
          end
        else
          render json: {msg: I18n.t('position.notice.has_comment')}, status: 500
        end
      end
    else
      render json: {msg: I18n.t('position.notice.not_found')}, status: 500
    end
  end
end
