class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :set_user_search, if: -> { current_user.present? }

  rescue_from ActionPolicy::Unauthorized, with: :user_not_authorized

  def set_user_search
    @q = User.all.ransack(params[:q])
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:display_name, :username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar_image, :bio, :display_name, :username, :private, :profile_banner, :remove_profile_banner, :website])
  end

  private

  def user_not_authorized
    flash[:alert] = "You're not authorized for that."
    redirect_back fallback_location: root_url
  end
end
