require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mycowriter
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Enable Rack::Attack for rate limiting
    config.middleware.use Rack::Attack

    # AdSense configuration (flag-driven, public-only).
    config.x.adsense.enabled = ActiveModel::Type::Boolean.new.cast(
      ENV.fetch("ADSENSE_ENABLED", "false")
    )
    config.x.adsense.client_id = ENV["ADSENSE_CLIENT_ID"]
    config.x.adsense.slots = ActiveSupport::OrderedOptions.new
    config.x.adsense.slots.inline = ENV["ADSENSE_SLOT_INLINE"]
    config.x.adsense.slots.footer = ENV["ADSENSE_SLOT_FOOTER"]
  end
end
