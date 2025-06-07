MissionControl::Jobs.configure do |config|
  # Disable HTTP Basic Auth for development environment
  config.http_basic_auth_enabled = false if Rails.env.development?
end
