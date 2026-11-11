# Emails every subscribed user when a product hits a new historical low.
class PriceDropAlertJob < ApplicationJob
  queue_as :default

  def perform(product, previous_low:, previous_price:)
    User.subscribed_to_price_alerts.find_each do |user|
      PriceAlertMailer.new_low(user, product, previous_low: previous_low, previous_price: previous_price).deliver_later
    end
  end
end
