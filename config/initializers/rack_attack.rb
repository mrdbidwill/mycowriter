class Rack::Attack
  ### Configure Cache ###

  # Use Rails cache for storing rate limit data
  Rack::Attack.cache.store = Rails.cache

  ### Throttle API Requests ###

  # Throttle all API requests by API key
  # 100 requests per hour per API key
  throttle("api/key", limit: 100, period: 1.hour) do |req|
    if req.path.start_with?("/api/v1")
      # Extract API key from Authorization header
      auth_header = req.env["HTTP_AUTHORIZATION"]
      if auth_header.present?
        token = auth_header.start_with?("Bearer ") ? auth_header.sub("Bearer ", "") : auth_header
        "api_key:#{token}"
      end
    end
  end

  # Throttle API requests by IP for requests without valid API key
  # 20 requests per hour per IP
  throttle("api/ip", limit: 20, period: 1.hour) do |req|
    if req.path.start_with?("/api/v1")
      # Only apply IP-based throttling if no valid API key is provided
      auth_header = req.env["HTTP_AUTHORIZATION"]
      if auth_header.blank?
        req.ip
      end
    end
  end

  ### Custom Throttle Response ###

  # Customize the response when rate limit is exceeded
  self.throttled_responder = lambda do |env|
    match_data = env["rack.attack.match_data"]
    now = match_data[:epoch_time]

    headers = {
      "Content-Type" => "application/json",
      "X-RateLimit-Limit" => match_data[:limit].to_s,
      "X-RateLimit-Remaining" => "0",
      "X-RateLimit-Reset" => (now + (match_data[:period] - now % match_data[:period])).to_s
    }

    [ 429, headers, [ { error: "Rate limit exceeded. Try again later." }.to_json ] ]
  end

  ### Track requests for rate limit headers ###

  # Store tracking data in request env for controllers to access
  Rack::Attack.track("api_requests") do |req|
    if req.path.start_with?("/api/v1")
      auth_header = req.env["HTTP_AUTHORIZATION"]
      if auth_header.present?
        token = auth_header.start_with?("Bearer ") ? auth_header.sub("Bearer ", "") : auth_header
        "api_key:#{token}"
      end
    end
  end
end
