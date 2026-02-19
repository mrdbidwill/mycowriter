module ApiAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_api_key!
    attr_reader :current_api_key, :current_user
  end

  private

  def authenticate_api_key!
    token = extract_token_from_header

    if token.blank?
      render_unauthorized("API key is required")
      return
    end

    @current_api_key = ApiKey.includes(:user).find_by(token: token)

    if @current_api_key.nil?
      render_unauthorized("Invalid API key")
      return
    end

    unless @current_api_key.valid_key?
      render_unauthorized("API key is expired or inactive")
      return
    end

    @current_user = @current_api_key.user
    @current_api_key.touch_last_used!
  end

  def extract_token_from_header
    # Support both "Bearer TOKEN" and "TOKEN" formats
    auth_header = request.headers["Authorization"]
    return nil if auth_header.blank?

    if auth_header.start_with?("Bearer ")
      auth_header.sub("Bearer ", "")
    else
      auth_header
    end
  end

  def render_unauthorized(message)
    render json: { error: message }, status: :unauthorized
  end
end
