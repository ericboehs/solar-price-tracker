require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @valid_attributes = {
      title: "EG4 LifePower4 Lithium Battery 48V 100Ah",
      url: "https://signaturesolar.com/test-base-product-#{SecureRandom.hex(4)}/",
      price: 1299.99
    }
  end

  test "should be valid with valid attributes" do
    product = Product.new(@valid_attributes)
    assert product.valid?
  end

  test "should require title" do
    product = Product.new(@valid_attributes.except(:title))
    assert_not product.valid?
    assert_includes product.errors[:title], "can't be blank"
  end

  test "should require url" do
    product = Product.new(@valid_attributes.except(:url))
    assert_not product.valid?
    assert_includes product.errors[:url], "can't be blank"
  end

  test "should require valid url format" do
    product = Product.new(@valid_attributes.merge(url: "not-a-url"))
    assert_not product.valid?
    assert_includes product.errors[:url], "is invalid"
  end

  test "should require price" do
    product = Product.new(@valid_attributes.except(:price))
    assert_not product.valid?
    assert_includes product.errors[:price], "can't be blank"
  end

  test "should require positive price" do
    product = Product.new(@valid_attributes.merge(price: -10))
    assert_not product.valid?
    assert_includes product.errors[:price], "must be greater than 0"
  end

  test "should require unique slug" do
    Product.create!(@valid_attributes.merge(url: "https://signaturesolar.com/test-unique-slug-1/"))
    duplicate_product = Product.new(@valid_attributes.merge(url: "https://signaturesolar.com/test-unique-slug-1/"))
    assert_not duplicate_product.valid?
    assert_includes duplicate_product.errors[:slug], "has already been taken"
  end

  test "should auto-generate slug from url" do
    product = Product.new(@valid_attributes.merge(
      url: "https://signaturesolar.com/eg4-lifepower4-lithium-battery-48v-100ah/"
    ))
    product.valid? # Trigger validations to generate slug
    assert_equal "eg4-lifepower4-lithium-battery-48v-100ah", product.slug
  end

  test "should not overwrite existing slug" do
    product = Product.new(@valid_attributes.merge(slug: "custom-slug"))
    product.valid?
    assert_equal "custom-slug", product.slug
  end

  test "should handle invalid URI in slug generation" do
    product = Product.new(@valid_attributes.merge(url: "http://[invalid]"))
    # Should not raise an error, just not set slug
    product.valid?
    # Slug should remain blank since URL is invalid, but will fail validation
    assert_nil product.slug
  end

  test "should handle URL with no path segments" do
    product = Product.new(@valid_attributes.merge(url: "https://signaturesolar.com/"))
    product.valid?
    # Should not set slug if there are no path segments
    assert_nil product.slug
  end

  test "should not generate slug when url is blank" do
    product = Product.new(@valid_attributes.merge(url: ""))
    product.valid?
    # Should not attempt slug generation if URL is blank (coverage for L23 return unless url.present?)
    assert_nil product.slug
  end

  test "display_price should format price as currency" do
    product = Product.new(@valid_attributes)
    assert_equal "$1299.99", product.display_price
  end

  test "display_price should handle prices with no cents" do
    product = Product.new(@valid_attributes.merge(price: 1000))
    assert_equal "$1000.00", product.display_price
  end

  test "scraped_recently? should return true for recent scrape" do
    product = Product.create!(@valid_attributes.merge(
      url: "https://signaturesolar.com/test-recent-scrape/",
      last_scraped_at: 1.hour.ago
    ))
    assert product.scraped_recently?
  end

  test "scraped_recently? should return false for old scrape" do
    product = Product.create!(@valid_attributes.merge(
      url: "https://signaturesolar.com/test-old-scrape/",
      last_scraped_at: 25.hours.ago
    ))
    assert_not product.scraped_recently?
  end

  test "scraped_recently? should return false for never scraped" do
    product = Product.create!(@valid_attributes.merge(
      url: "https://signaturesolar.com/test-never-scraped/"
    ))
    assert_not product.scraped_recently?
  end

  test "recently_scraped scope should include recent products" do
    recent_product = Product.create!(@valid_attributes.merge(
      url: "https://signaturesolar.com/test-recent-product/",
      last_scraped_at: 1.hour.ago
    ))
    old_product = Product.create!(@valid_attributes.merge(
      url: "https://signaturesolar.com/test-old-product/",
      last_scraped_at: 25.hours.ago
    ))

    recent_products = Product.recently_scraped
    assert_includes recent_products, recent_product
    assert_not_includes recent_products, old_product
  end

  test "needs_scraping scope should include never scraped and old products" do
    never_scraped = Product.create!(@valid_attributes.merge(
      url: "https://signaturesolar.com/test-never-scraped-scope/"
    ))
    old_scraped = Product.create!(@valid_attributes.merge(
      url: "https://signaturesolar.com/test-old-scraped-scope/",
      last_scraped_at: 25.hours.ago
    ))
    recently_scraped = Product.create!(@valid_attributes.merge(
      url: "https://signaturesolar.com/test-recently-scraped-scope/",
      last_scraped_at: 1.hour.ago
    ))

    needs_scraping = Product.needs_scraping
    assert_includes needs_scraping, never_scraped
    assert_includes needs_scraping, old_scraped
    assert_not_includes needs_scraping, recently_scraped
  end
end
