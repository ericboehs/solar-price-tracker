# Configure Mission Control Jobs authentication
Rails.application.configure do
  config.mission_control.jobs.base_controller_class = "ApplicationController"
end
