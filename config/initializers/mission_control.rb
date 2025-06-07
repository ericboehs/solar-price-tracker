# Configure Mission Control Jobs authentication
Rails.application.configure do
  config.mission_control.jobs.http_basic_auth_user = "admin"
  config.mission_control.jobs.http_basic_auth_password = "password"
end
