require "test_helper"

class PriceDropAlertJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "emails only users subscribed to price alerts" do
    users(:one).update!(price_alerts: true)
    users(:two).update!(price_alerts: false)
    product = products(:battery_48v)

    assert_enqueued_emails 1 do
      PriceDropAlertJob.perform_now(product, previous_low: BigDecimal("1399.99"), previous_price: BigDecimal("1499.99"))
    end
    assert_enqueued_email_with PriceAlertMailer, :new_low,
      args: [ users(:one), product, { previous_low: BigDecimal("1399.99"), previous_price: BigDecimal("1499.99") } ]
  end
end
