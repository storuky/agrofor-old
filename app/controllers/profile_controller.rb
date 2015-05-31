class ProfileController < ApplicationController
  before_action :set_profile_params, only: [:edit]

  def index
  end

  def avatar
    current_user.avatar = params[:avatar]

    if current_user.save
      render json: current_user.info
    else
      render json: {msg: I18n.t("file.format.error"), type: 'error'}.to_json, status: 500
    end
  end

  def edit
    if current_user.update(@profile_params)
      render json: current_user.info
    else
      render json: {msg: I18n.t("profile.update.error"), type: 'error'}, status: 500
    end
  end

  def show
    user = User.where(id: params[:id]).first
    if user
      render json: {
        user_data: user.info
      }
    else
      render json: {
        msg: I18n.t("user.notice.not_found")
      }, status: 500
    end
  end

  def completed
    user = User.where(id: params[:user_id]).first
    if user
      render json: {
        positions: user.reputations.includes(:position).includes(:sender).as_json(:include => {:sender => {}, :position => {include: :user} })
      }
    else
      render json: {
        msg: I18n.t("user.notice.not_found")
      }, status: 500
    end
  end

  def opened
    user = User.where(id: params[:user_id]).first
    if user
      render json: {
        positions: user.positions.where(status: 'opened')
      }
    else
      render json: {
        msg: I18n.t("user.notice.not_found")
      }, status: 500
    end
  end

  private
    def set_profile_params
      @profile_params = params.permit(:additional, :address, :city, :company, :lat, :lng, :name, :phone => [])
    end
end
