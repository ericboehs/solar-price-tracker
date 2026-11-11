require "test_helper"

class PriceAlertMailerTest < ActionMailer::TestCase
  test "new_low" do
    user = users(:one)
    product = products(:battery_48v) # 1299.99
    mail = PriceAlertMailer.new_low(user, product, previous_low: BigDecimal("1349.99"), previous_price: BigDecimal("1499.99"))

    assert_equal [ user.email_address ], mail.to
    assert_match "New low:", mail.subject
    assert_match "$1299.99", mail.subject
    assert_match %r{<https?://.+/unsubscribe/.+>}, mail["List-Unsubscribe"].to_s

    text = mail.text_part.decoded
    assert_match "$1,499.99 ($200.00 off)", text
    assert_match "Previous low:  $1,349.99", text
    assert_match "/products/#{product.slug}", text
    assert_match "/unsubscribe/", mail.html_part.decoded
  end
end
