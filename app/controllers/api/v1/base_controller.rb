module Api
  module V1
    class BaseController < ActionController::API
      rescue_from StandardError do |e|
        Rails.logger.error "API Error: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end
  end
end
