class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :apply_global_privacy_signals

  private

  def apply_global_privacy_signals
    return unless request.headers["Sec-GPC"] == "1"

    cookies[:adsense_opt_out] = {
      value: "true",
      expires: 1.year,
      same_site: :lax
    }
  end

  def adsense_authenticated?
    return user_signed_in? if respond_to?(:user_signed_in?)
    return current_user.present? if respond_to?(:current_user)
    return logged_in? if respond_to?(:logged_in?)
    return authenticated? if respond_to?(:authenticated?)
    return session[:user_id].present? if respond_to?(:session) && session.is_a?(ActionDispatch::Request::Session)

    false
  end

  def adsense_opted_out?
    cookies[:adsense_opt_out].to_s == "true" || request.headers["Sec-GPC"] == "1"
  end
end
