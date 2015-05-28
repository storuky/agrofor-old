class SettingsController < ApplicationController
  def index

  end

  def update
    user_params = params.permit(:locale, :currency_id, :sms_notify, :email_notify)
    if current_user.update(user_params)
      render json: {msg: "Настройки успешно обновлены"}
    else
      render json: {msg: "Ошибка обновления настроек"}, status: 500
    end
  end
end
