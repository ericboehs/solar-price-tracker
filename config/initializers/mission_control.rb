# Disable Mission Control Jobs HTTP Basic Auth in development
if Rails.env.development?
  Rails.application.config.to_prepare do
    MissionControl::Jobs::ApplicationController.class_eval do
      skip_before_action :authenticate_by_http_basic
    end
  end
end
