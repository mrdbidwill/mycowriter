class Rack::Attack
  ### Configure Cache ###

  # Use Rails cache for storing rate limit data
  Rack::Attack.cache.store = Rails.cache

  ### Throttle API Requests ###

  # Throttle API requests by IP
  # 100 requests per hour per IP
  throttle("api/ip", limit: 100, period: 1.hour) do |req|
    req.ip if req.path.start_with?("/api/v1")
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

  ### Tracking is handled by Rack::Attack ###
end
