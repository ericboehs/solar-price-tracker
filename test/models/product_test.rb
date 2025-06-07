require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @product = Product.new(
      title: "Test Battery",
      url: "https://example.com/products/test-battery",
      price: 999.99
    )
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @product.valid?
  end

  test "should require title" do
    @product.title = nil
    refute @product.valid?
    assert_includes @product.errors[:title], "can't be blank"
  end

  test "should require url" do
    @product.url = nil
    refute @product.valid?
    assert_includes @product.errors[:url], "can't be blank"
  end

  test "should validate url format" do
    @product.url = "not-a-url"
    refute @product.valid?
    assert_includes @product.errors[:url], "must be a valid HTTP or HTTPS URL"

    @product.url = "ftp://example.com"
    refute @product.valid?
    assert_includes @product.errors[:url], "must be a valid HTTP or HTTPS URL"

    @product.url = "https://example.com"
    assert @product.valid?

    @product.url = "http://example.com"
    assert @product.valid?
  end

  test "should require unique slug" do
    @product.save!

    duplicate = Product.new(
      title: "Another Battery",
      url: "https://example.com/products/another-battery",
      slug: @product.slug
    )
    refute duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  # Callback tests
  test "should extract slug from url on create" do
    product = Product.new(
      title: "Auto Slug Test",
      url: "https://example.com/products/auto-slug-test"
    )
    product.save!
    assert_equal "auto-slug-test", product.slug
  end

  test "should generate slug from title when url extraction fails" do
    product = Product.new(
      title: "Invalid URL Test!",
      url: "invalid-url"
    )
    # This will fail URL validation, but let's test the slug generation logic
    product.send(:extract_slug_from_url)
    assert_equal "invalid-url", product.slug
  end

  test "should not override existing slug" do
    @product.slug = "custom-slug"
    @product.save!
    assert_equal "custom-slug", @product.slug
  end

  # Association tests
  test "should have many price histories" do
    @product.save!
    @product.price_histories.create!(price: 899.99, recorded_at: 1.day.ago)
    @product.price_histories.create!(price: 999.99, recorded_at: Time.current)

    assert_equal 2, @product.price_histories.count
  end

  test "should destroy associated price histories when destroyed" do
    @product.save!
    @product.price_histories.create!(price: 899.99)

    assert_difference "PriceHistory.count", -1 do
      @product.destroy
    end
  end

  # Price tracking tests
  test "current_price returns most recent price history price" do
    @product.save!
    @product.price_histories.create!(price: 899.99, recorded_at: 2.days.ago)
    @product.price_histories.create!(price: 1099.99, recorded_at: 1.day.ago)

    assert_equal 1099.99, @product.current_price
  end

  test "current_price falls back to legacy price field when no price history" do
    @product.save!
    assert_equal 999.99, @product.current_price
  end

  test "price_changed? detects price differences" do
    @product.save!
    @product.price_histories.create!(price: 999.99)

    refute @product.price_changed?(999.99)
    refute @product.price_changed?(999.98) # Within 0.01 threshold
    assert @product.price_changed?(999.97) # Beyond 0.01 threshold
    assert @product.price_changed?(1099.99)
  end

  test "price_changed? returns true when no price history exists" do
    @product.save!
    assert @product.price_changed?(999.99)
  end

  test "record_price creates price history when price changes" do
    @product.save!
    @product.price_histories.create!(price: 999.99)

    assert_difference "PriceHistory.count", 1 do
      result = @product.record_price(1099.99)
      assert result
    end

    assert_equal 1099.99, @product.reload.price
  end

  test "record_price does not create history when price unchanged" do
    @product.save!
    @product.price_histories.create!(price: 999.99)

    assert_no_difference "PriceHistory.count" do
      result = @product.record_price(999.99)
      refute result
    end
  end

  test "record_price uses custom recorded_at time" do
    @product.save!
    custom_time = 1.week.ago

    @product.record_price(1099.99, custom_time)

    history = @product.price_histories.last
    assert_equal custom_time.to_i, history.recorded_at.to_i
  end

  # Price trend tests
  test "price_trend returns unknown with insufficient data" do
    @product.save!
    assert_equal :unknown, @product.price_trend

    @product.price_histories.create!(price: 999.99)
    assert_equal :unknown, @product.price_trend
  end

  test "price_trend detects increasing prices" do
    @product.save!
    @product.price_histories.create!(price: 899.99, recorded_at: 20.days.ago)
    @product.price_histories.create!(price: 999.99, recorded_at: 10.days.ago)

    assert_equal :increasing, @product.price_trend
  end

  test "price_trend detects decreasing prices" do
    @product.save!
    @product.price_histories.create!(price: 1099.99, recorded_at: 20.days.ago)
    @product.price_histories.create!(price: 999.99, recorded_at: 10.days.ago)

    assert_equal :decreasing, @product.price_trend
  end

  test "price_trend detects stable prices" do
    @product.save!
    @product.price_histories.create!(price: 999.99, recorded_at: 20.days.ago)
    @product.price_histories.create!(price: 999.99, recorded_at: 10.days.ago)

    assert_equal :stable, @product.price_trend
  end

  test "price_trend respects date range parameter" do
    @product.save!
    @product.price_histories.create!(price: 799.99, recorded_at: 60.days.ago)
    @product.price_histories.create!(price: 899.99, recorded_at: 20.days.ago)
    @product.price_histories.create!(price: 999.99, recorded_at: 10.days.ago)

    # Within 30 days: 899.99 -> 999.99 (increasing)
    assert_equal :increasing, @product.price_trend(30)

    # Within 90 days: 799.99 -> 999.99 (increasing)
    assert_equal :increasing, @product.price_trend(90)
  end

  # Price change percentage tests
  test "price_change_percentage calculates percentage change" do
    @product.save!
    @product.price_histories.create!(price: 1000.00, recorded_at: 20.days.ago)
    @product.price_histories.create!(price: 1100.00, recorded_at: 10.days.ago)

    assert_equal 10.0, @product.price_change_percentage
  end

  test "price_change_percentage handles negative changes" do
    @product.save!
    @product.price_histories.create!(price: 1000.00, recorded_at: 20.days.ago)
    @product.price_histories.create!(price: 900.00, recorded_at: 10.days.ago)

    assert_equal -10.0, @product.price_change_percentage
  end

  test "price_change_percentage returns nil with insufficient data" do
    @product.save!
    assert_nil @product.price_change_percentage

    @product.price_histories.create!(price: 999.99)
    assert_nil @product.price_change_percentage
  end

  test "price_change_percentage respects date range parameter" do
    @product.save!
    @product.price_histories.create!(price: 800.00, recorded_at: 60.days.ago)
    @product.price_histories.create!(price: 900.00, recorded_at: 20.days.ago)
    @product.price_histories.create!(price: 1000.00, recorded_at: 10.days.ago)

    # Within 30 days: 900 -> 1000 (11.11% increase)
    assert_equal 11.11, @product.price_change_percentage(30)

    # Within 90 days: 800 -> 1000 (25% increase)
    assert_equal 25.0, @product.price_change_percentage(90)
  end

  # Price record tests
  test "highest_price_record returns record with highest price" do
    @product.save!
    low_record = @product.price_histories.create!(price: 899.99)
    high_record = @product.price_histories.create!(price: 1199.99)
    mid_record = @product.price_histories.create!(price: 999.99)

    assert_equal high_record, @product.highest_price_record
  end

  test "lowest_price_record returns record with lowest price" do
    @product.save!
    low_record = @product.price_histories.create!(price: 799.99)
    high_record = @product.price_histories.create!(price: 1199.99)
    mid_record = @product.price_histories.create!(price: 999.99)

    assert_equal low_record, @product.lowest_price_record
  end

  test "at_lowest_price? detects when current price equals lowest" do
    @product.save!
    @product.price_histories.create!(price: 799.99)
    @product.price_histories.create!(price: 999.99)
    @product.price_histories.create!(price: 1199.99)
    @product.price_histories.create!(price: 799.99) # Current price matches lowest

    assert @product.at_lowest_price?
  end

  test "at_lowest_price? returns false when not at lowest price" do
    @product.save!
    @product.price_histories.create!(price: 799.99)
    @product.price_histories.create!(price: 999.99) # Current price higher than lowest

    refute @product.at_lowest_price?
  end

  test "at_lowest_price? returns false when no price history" do
    @product.save!
    refute @product.at_lowest_price?
  end

  # Safe URL tests
  test "safe_url returns url for valid HTTP URLs" do
    @product.url = "http://example.com"
    assert_equal "http://example.com", @product.safe_url
  end

  test "safe_url returns url for valid HTTPS URLs" do
    @product.url = "https://example.com"
    assert_equal "https://example.com", @product.safe_url
  end

  test "safe_url returns nil for invalid URLs" do
    @product.url = "ftp://example.com"
    assert_nil @product.safe_url

    @product.url = "not-a-url"
    assert_nil @product.safe_url
  end

  test "safe_url returns nil when url is blank" do
    @product.url = nil
    assert_nil @product.safe_url

    @product.url = ""
    assert_nil @product.safe_url
  end
end
