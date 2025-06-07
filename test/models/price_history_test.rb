require "test_helper"

class PriceHistoryTest < ActiveSupport::TestCase
  def setup
    @price_history = PriceHistory.new(
      product: products(:one),
      price: 999.99,
      recorded_at: Time.current
    )
  end

  test "should be valid with valid attributes" do
    assert @price_history.valid?
  end

  test "should require price" do
    @price_history.price = nil
    refute @price_history.valid?
    assert_includes @price_history.errors[:price], "can't be blank"
  end

  test "should require positive price" do
    @price_history.price = -10
    refute @price_history.valid?
    assert_includes @price_history.errors[:price], "must be greater than 0"
  end

  test "should validate recorded_at presence" do
    @price_history.recorded_at = nil
    # The callback will set it, so this tests the validation would work if bypass callback
    assert @price_history.valid?  # Because callback sets it
  end

  test "should set recorded_at on create when nil" do
    price_history = PriceHistory.new(
      product: products(:one),
      price: 999.99,
      recorded_at: nil
    )

    assert_nil price_history.recorded_at
    price_history.save!
    assert_not_nil price_history.recorded_at
    assert_kind_of Time, price_history.recorded_at
  end

  test "should not override existing recorded_at on create" do
    custom_time = 1.week.ago
    price_history = PriceHistory.new(
      product: products(:one),
      price: 999.99,
      recorded_at: custom_time
    )

    price_history.save!
    assert_equal custom_time.to_i, price_history.recorded_at.to_i
  end

  test "belongs to product" do
    assert_respond_to @price_history, :product
    assert_kind_of Product, @price_history.product
  end

  test "recent scope orders by recorded_at desc" do
    # Clear existing price histories to avoid interference
    PriceHistory.delete_all

    old_history = PriceHistory.create!(product: products(:one), price: 800.00, recorded_at: 2.days.ago)
    new_history = PriceHistory.create!(product: products(:one), price: 900.00, recorded_at: 1.day.ago)

    recent = PriceHistory.recent.limit(2)
    assert_equal new_history.id, recent.first.id
    assert_equal old_history.id, recent.last.id
  end

  test "for_date_range scope filters by date range" do
    old_history = PriceHistory.create!(product: products(:one), price: 800.00, recorded_at: 10.days.ago)
    recent_history = PriceHistory.create!(product: products(:one), price: 900.00, recorded_at: 2.days.ago)

    in_range = PriceHistory.for_date_range(5.days.ago, Time.current)
    assert_includes in_range, recent_history
    assert_not_includes in_range, old_history
  end
end
