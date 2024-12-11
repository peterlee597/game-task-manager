# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end
  def callback
    # This action handles the OAuth callback
    auth_code = params[:code]

    # Exchange the auth code for an access token
    token_response = some_oauth_service.exchange_code_for_token(auth_code)

    # Store the token in the session or database
    session[:google_token] = token_response["access_token"]

    # Redirect to the desired page after successful login
    redirect_to root_path, notice: "Signed in successfully with Google!"
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end
  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
