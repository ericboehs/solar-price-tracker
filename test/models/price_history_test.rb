require "test_helper"

class PriceHistoryTest < ActiveSupport::TestCase
  test "should belong to product" do
    price_history = price_histories(:battery_initial_price)
    assert_equal products(:battery_48v), price_history.product
  end

  test "should validate presence of price" do
    price_history = PriceHistory.new(product: products(:battery_48v), recorded_at: Time.current)
    assert_not price_history.valid?
    assert_includes price_history.errors[:price], "can't be blank"
  end

  test "should validate price is greater than zero" do
    price_history = PriceHistory.new(
      product: products(:battery_48v),
      price: -10.00,
      recorded_at: Time.current
    )
    assert_not price_history.valid?
    assert_includes price_history.errors[:price], "must be greater than 0"
  end

  test "should validate presence of recorded_at" do
    price_history = PriceHistory.new(product: products(:battery_48v), price: 100.00)
    assert_not price_history.valid?
    assert_includes price_history.errors[:recorded_at], "can't be blank"
  end

  test "price_change_from_previous should calculate difference from previous entry" do
    price_history = price_histories(:battery_price_drop)
    change = price_history.price_change_from_previous
    assert_equal -100.00, change
  end

  test "price_change_from_previous should return nil if no previous entry" do
    price_history = price_histories(:battery_initial_price)
    change = price_history.price_change_from_previous
    assert_nil change
  end

  test "price_change_percentage_from_previous should calculate percentage change" do
    price_history = price_histories(:battery_price_drop)
    percentage = price_history.price_change_percentage_from_previous
    assert_in_delta -7.69, percentage, 0.01
  end

  test "price_change_percentage_from_previous should return nil if no previous entry" do
    price_history = price_histories(:battery_initial_price)
    percentage = price_history.price_change_percentage_from_previous
    assert_nil percentage
  end
end
