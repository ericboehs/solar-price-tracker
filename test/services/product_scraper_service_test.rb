require "test_helper"

class ProductScraperServiceTest < ActiveSupport::TestCase
  def setup
    @service = ProductScraperService.new("https://example.com")
  end

  test "initializes with search URL" do
    service = ProductScraperService.new("test_url")
    assert_equal "test_url", service.instance_variable_get(:@search_url)
  end

  test "extract_price handles basic price format" do
    assert_equal 999.99, @service.send(:extract_price, "$999.99")
  end

  test "extract_price handles various formats" do
    assert_equal 1234.0, @service.send(:extract_price, "$1,234.00")
    assert_equal 99.5, @service.send(:extract_price, "99.50")
    assert_equal 100.0, @service.send(:extract_price, "$100")
    assert_nil @service.send(:extract_price, "Not a price")
    assert_nil @service.send(:extract_price, nil)
  end

  test "extract_price returns lowest when multiple found" do
    assert_equal 99.99, @service.send(:extract_price, "$199.99 $99.99")
    assert_equal 50.0, @service.send(:extract_price, "$100.00 Sale: $50.00")
  end

  test "extract_price_value extracts numeric value" do
    assert_equal 999.99, @service.send(:extract_price_value, "$999.99")
    assert_equal 1234.0, @service.send(:extract_price_value, "$1,234.00")
    assert_nil @service.send(:extract_price_value, "No price here")
    assert_nil @service.send(:extract_price_value, nil)
  end

  test "extract_slug_from_url extracts slug correctly" do
    assert_equal "test-battery-product", @service.send(:extract_slug_from_url, "https://example.com/products/test-battery-product")
    assert_equal "battery-pack", @service.send(:extract_slug_from_url, "https://example.com/battery-pack?param=value")
    assert_equal "simple-slug", @service.send(:extract_slug_from_url, "/products/simple-slug")
    assert_nil @service.send(:extract_slug_from_url, "")
    assert_nil @service.send(:extract_slug_from_url, nil)
  end

  test "extract_slug_from_url handles invalid URLs" do
    assert_equal "not-a-valid-url", @service.send(:extract_slug_from_url, "not-a-valid-url")
    assert_nil @service.send(:extract_slug_from_url, "http://[invalid")
  end

  test "extract_slug_from_url cleans special characters" do
    assert_equal "test-battery", @service.send(:extract_slug_from_url, "https://example.com/test-battery!")
    assert_equal "battery123abc", @service.send(:extract_slug_from_url, "https://example.com/battery123%abc")
  end

  test "bundle_product detection by title" do
    card = Nokogiri::HTML("<div></div>").at("div")
    assert @service.send(:bundle_product?, card, { title: "Battery Bundle Pack" })
    assert @service.send(:bundle_product?, card, { title: "BNDL-123 Special" })
    refute @service.send(:bundle_product?, card, { title: "Regular Battery" })
    refute @service.send(:bundle_product?, card, { title: nil })
  end

  test "bundle_product detection by options button" do
    card = Nokogiri::HTML("<div><button>View Options</button></div>").at("div")
    assert @service.send(:bundle_product?, card, { title: "Regular Battery" })
  end

  test "single_product_page detection" do
    doc_with_details = Nokogiri::HTML('<html><body><div class="product-details"></div></body></html>')
    assert @service.send(:single_product_page?, doc_with_details)

    doc_with_meta = Nokogiri::HTML('<html><head><meta property="og:type" content="product"></head></html>')
    assert @service.send(:single_product_page?, doc_with_meta)

    regular_doc = Nokogiri::HTML('<html><body><div class="product-list"></div></body></html>')
    refute @service.send(:single_product_page?, regular_doc)
  end

  test "scrape_products handles network errors gracefully" do
    @service.expects(:fetch_document).raises(StandardError.new("Network error"))
    products = @service.scrape_products
    assert_equal [], products
  end
end
