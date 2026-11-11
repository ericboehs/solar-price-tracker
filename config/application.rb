require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SolarPriceTracker
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Central Time (US & Canada)"

    # Public sign-ups. Closed by default in production; override with
    # REGISTRATIONS_OPEN=true|false.
    config.x.registrations_open =
      ENV.fetch("REGISTRATIONS_OPEN") { Rails.env.production? ? "false" : "true" } == "true"

    # Deny powerful browser features (Rails' permissions_policy still emits the
    # legacy Feature-Policy header, which browsers ignore).
    config.action_dispatch.default_headers["Permissions-Policy"] =
      "camera=(), microphone=(), geolocation=(), payment=(), usb=(), gyroscope=(), magnetometer=(), accelerometer=(), fullscreen=(self), browsing-topics=()"

    # Active Storage isn't used for uploads; skip the image_processing check.
    config.active_storage.variant_processor = :disabled
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
