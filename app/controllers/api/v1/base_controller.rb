module Api
  module V1
    class BaseController < ActionController::API
      include ApiAuthenticatable

      after_action :set_rate_limit_headers

      rescue_from StandardError do |e|
        Rails.logger.error "API Error: #{e.class} - #{e.message}\n#{e.backtrace.join("\n")}"
        render json: { error: "Internal server error" }, status: :internal_server_error
      end

      private

      def set_rate_limit_headers
        # Calculate rate limit info for this API key
        return unless current_api_key

        limit = 100 # 100 requests per hour
        period = 1.hour.to_i

        # Use Rails cache to track requests
        cache_key = "rate_limit:api_key:#{current_api_key.id}:#{Time.now.to_i / period}"
        count = Rails.cache.read(cache_key) || 0
        remaining = [limit - count, 0].max

        # Calculate reset time (next hour boundary)
        now = Time.now.to_i
        reset_time = now + (period - (now % period))

        response.headers["X-RateLimit-Limit"] = limit.to_s
        response.headers["X-RateLimit-Remaining"] = remaining.to_s
        response.headers["X-RateLimit-Reset"] = reset_time.to_s
      end
    end
  end
end
