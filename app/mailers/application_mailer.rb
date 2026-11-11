class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Solar Price Tracker <alerts@solar-prices.apps.boehs.com>")
  layout "mailer"
end
