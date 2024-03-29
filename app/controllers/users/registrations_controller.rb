class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    geo = Geocoder.search(request.remote_ip).first
    
    resource.address = geo.country
    resource.city = geo.city
    resource.lng = geo.longitude
    resource.lat = geo.latitude

    if ["ru", "by", "ua", "kz"].include? extract_locale_from_accept_language_header
      resource.locale = "ru"
      resource.currency_id = 1
    else
      resource.locale = "en"
      resource.currency_id = 2
    end

    resource.save

    unless resource.persisted?
      render json: {
        msg: resource.errors.full_messages.first
      }, status: 500
    else
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        render json: {
          msg: "Вы успешно зарегистрированы в системе",
          user_id: resource.id
        }
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # You can put the params you want to permit in the empty array.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
    
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  private
    def extract_locale_from_accept_language_header
      request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    end
    
    def sign_up_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
    end
end
