require "test_helper"

class ProductScraperServiceTest < ActiveSupport::TestCase
  def setup
    @service = ProductScraperService.new("https://signaturesolar.com/search?q=battery")
    @sample_html = <<~HTML
      <div class="woocommerce">
        <ul class="products">
          <li class="product">
            <a href="/eg4-lifepower4-lithium-battery-48v-100ah/" class="woocommerce-LoopProduct-link">
              <h2 class="woocommerce-loop-product__title">EG4 LifePower4 Lithium Battery 48V 100Ah</h2>
              <span class="price">
                <span class="woocommerce-Price-amount">$1,299.99</span>
              </span>
              <img src="https://signaturesolar.com/wp-content/uploads/2023/10/battery.jpg" alt="Battery">
            </a>
          </li>
          <li class="product">
            <a href="/eg4-6000xp-inverter/" class="woocommerce-LoopProduct-link">
              <h2 class="woocommerce-loop-product__title">EG4 6000XP Inverter</h2>
              <span class="price">
                <del><span class="woocommerce-Price-amount">$1,599.99</span></del>
                <ins><span class="woocommerce-Price-amount">$1,399.99</span></ins>
              </span>
              <img src="https://signaturesolar.com/wp-content/uploads/2023/10/inverter.jpg" alt="Inverter">
            </a>
          </li>
          <li class="product">
            <a href="https://external-site.com/invalid-product/" class="woocommerce-LoopProduct-link">
              <h2 class="woocommerce-loop-product__title">External Product</h2>
              <span class="price">
                <span class="woocommerce-Price-amount">$999.99</span>
              </span>
            </a>
          </li>
        </ul>
      </div>
    HTML
  end

  test "scrape should return empty array when page fetch fails" do
    # Mock network failure
    URI.expects(:open).raises(OpenURI::HTTPError.new("404 Not Found", nil))

    result = @service.scrape
    assert_empty result
  end

  test "scrape should extract and create products from valid HTML" do
    # Clear any existing products to get clean count
    Product.delete_all

    # Mock successful page fetch
    page = Nokogiri::HTML(@sample_html)
    @service.expects(:fetch_page).returns(page)

    assert_difference "Product.count", 2 do
      products = @service.scrape
      assert_equal 2, products.length
    end

    # Check first product (regular price)
    battery = Product.find_by(slug: "eg4-lifepower4-lithium-battery-48v-100ah")
    assert battery
    assert_equal "EG4 LifePower4 Lithium Battery 48V 100Ah", battery.title
    assert_equal "https://signaturesolar.com/eg4-lifepower4-lithium-battery-48v-100ah/", battery.url
    assert_equal 1299.99, battery.price
    assert_equal "https://signaturesolar.com/wp-content/uploads/2023/10/battery.jpg", battery.image_url
    assert_not_nil battery.last_scraped_at

    # Check second product (sale price)
    inverter = Product.find_by(slug: "eg4-6000xp-inverter")
    assert inverter
    assert_equal "EG4 6000XP Inverter", inverter.title
    assert_equal 1399.99, inverter.price # Should use sale price
  end

  test "scrape should update existing products" do
    # Clear any existing products to avoid conflicts
    Product.delete_all

    # Create existing product that matches one in our test HTML
    existing_product = Product.create!(
      title: "Old Title",
      url: "https://signaturesolar.com/eg4-lifepower4-lithium-battery-48v-100ah/",
      slug: "eg4-lifepower4-lithium-battery-48v-100ah",
      price: 999.99,
      last_scraped_at: 1.day.ago
    )

    page = Nokogiri::HTML(@sample_html)
    @service.expects(:fetch_page).returns(page)

    # Should have one less creation since one product already exists
    assert_difference "Product.count", 1 do
      @service.scrape
    end

    existing_product.reload
    assert_equal "EG4 LifePower4 Lithium Battery 48V 100Ah", existing_product.title
    assert_equal 1299.99, existing_product.price
    assert existing_product.last_scraped_at > 1.hour.ago
  end

  test "extract_product_data should handle missing elements gracefully" do
    minimal_html = '<div class="product"><a href="/test/" class="woocommerce-LoopProduct-link"><h2 class="woocommerce-loop-product__title">Test Product</h2></a></div>'
    element = Nokogiri::HTML(minimal_html).at_css(".product")

    data = @service.send(:extract_product_data, element)

    assert_equal "Test Product", data[:title]
    assert_equal "https://signaturesolar.com/test/", data[:url]
    assert_nil data[:price]
    assert_nil data[:image_url]
  end

  test "extract_price_text should prioritize sale price over regular price" do
    sale_html = <<~HTML
      <div class="price">
        <del><span class="woocommerce-Price-amount">$1,999.99</span></del>
        <ins><span class="woocommerce-Price-amount">$1,499.99</span></ins>
      </div>
    HTML
    element = Nokogiri::HTML(sale_html)

    price_text = @service.send(:extract_price_text, element)
    assert_equal "$1,499.99", price_text
  end

  test "extract_price_text should fallback to regular price" do
    regular_html = '<div class="price"><span class="woocommerce-Price-amount">$999.99</span></div>'
    element = Nokogiri::HTML(regular_html)

    price_text = @service.send(:extract_price_text, element)
    assert_equal "$999.99", price_text
  end

  test "parse_price should extract numeric value from currency string" do
    assert_equal 1299.99, @service.send(:parse_price, "$1,299.99")
    assert_equal 999.0, @service.send(:parse_price, "$999")
    assert_equal 1500.50, @service.send(:parse_price, "$ 1,500.50")
    assert_nil @service.send(:parse_price, "Invalid price")
    assert_nil @service.send(:parse_price, "")
    assert_nil @service.send(:parse_price, nil)
  end

  test "extract_slug_from_url should extract product slug from URL" do
    url = "https://signaturesolar.com/eg4-lifepower4-lithium-battery-48v-100ah/"
    slug = @service.send(:extract_slug_from_url, url)
    assert_equal "eg4-lifepower4-lithium-battery-48v-100ah", slug
  end

  test "extract_slug_from_url should handle URLs without trailing slash" do
    url = "https://signaturesolar.com/products/battery"
    slug = @service.send(:extract_slug_from_url, url)
    assert_equal "battery", slug
  end

  test "extract_slug_from_url should handle invalid URLs" do
    # Test actual invalid URL that would cause URI parse error
    slug = @service.send(:extract_slug_from_url, "http://[invalid]")
    assert_nil slug
  end

  test "find_or_create_product should skip products without URL" do
    product_data = { title: "Test Product", price: 99.99 }
    result = @service.send(:find_or_create_product, product_data)
    assert_nil result
  end

  test "find_or_create_product should skip products with invalid URL" do
    product_data = {
      title: "Test Product",
      price: 99.99,
      url: "not-a-valid-url"
    }
    result = @service.send(:find_or_create_product, product_data)
    assert_nil result
  end

  test "find_or_create_product should create new valid product" do
    product_data = {
      title: "New Test Product",
      url: "https://signaturesolar.com/new-test-product/",
      price: 199.99,
      image_url: "https://example.com/image.jpg"
    }

    assert_difference "Product.count", 1 do
      product = @service.send(:find_or_create_product, product_data)
      assert product
      assert_equal "New Test Product", product.title
      assert_equal "new-test-product", product.slug
    end
  end

  test "find_or_create_product should update existing product" do
    existing = Product.create!(
      title: "Old Title",
      url: "https://signaturesolar.com/existing-product/",
      slug: "existing-product",
      price: 99.99
    )

    product_data = {
      title: "Updated Title",
      url: "https://signaturesolar.com/existing-product/",
      price: 149.99,
      image_url: "https://example.com/new-image.jpg"
    }

    assert_no_difference "Product.count" do
      product = @service.send(:find_or_create_product, product_data)
      assert_equal existing.id, product.id
    end

    existing.reload
    assert_equal "Updated Title", existing.title
    assert_equal 149.99, existing.price
    assert_equal "https://example.com/new-image.jpg", existing.image_url
  end

  # Coverage for L18: @scraped_products << product if product (when product is nil)
  test "scrape should handle nil products from find_or_create_product" do
    html_with_invalid_product = <<~HTML
      <div class="woocommerce">
        <ul class="products">
          <li class="product">
            <a href="/invalid-product/" class="woocommerce-LoopProduct-link">
              <h2 class="woocommerce-loop-product__title">Invalid Product</h2>
              <span class="price">
                <span class="woocommerce-Price-amount">$999.99</span>
              </span>
            </a>
          </li>
        </ul>
      </div>
    HTML

    page = Nokogiri::HTML(html_with_invalid_product)
    @service.expects(:fetch_page).returns(page)

    # Mock find_or_create_product to return nil (simulating failure)
    @service.expects(:find_or_create_product).returns(nil)

    result = @service.scrape
    assert_empty result
  end

  # Coverage for L56: title_element&.text&.strip (when title_element is nil)
  test "extract_product_data should handle missing title" do
    html_without_title = '<div class="product"><a href="/test/" class="woocommerce-LoopProduct-link"></a></div>'
    element = Nokogiri::HTML(html_without_title).at_css(".product")

    data = @service.send(:extract_product_data, element)
    assert_nil data[:title]
  end

  # Coverage for L60: if link_element (when link_element is nil)
  test "extract_product_data should handle missing link" do
    html_without_link = '<div class="product"><h2 class="woocommerce-loop-product__title">Test Product</h2></div>'
    element = Nokogiri::HTML(html_without_link).at_css(".product")

    data = @service.send(:extract_product_data, element)
    assert_nil data[:url]
  end

  # Coverage for L73: data[:image_url] = src if src && !src.include?("placeholder")
  test "extract_product_data should handle placeholder images" do
    html_with_placeholder = <<~HTML
      <div class="product">
        <a href="/test/" class="woocommerce-LoopProduct-link">
          <h2 class="woocommerce-loop-product__title">Test Product</h2>
          <img src="https://example.com/placeholder.jpg" alt="Product">
        </a>
      </div>
    HTML
    element = Nokogiri::HTML(html_with_placeholder).at_css(".product")

    data = @service.send(:extract_product_data, element)
    assert_nil data[:image_url]
  end

  test "extract_product_data should accept non-placeholder images" do
    html_with_real_image = <<~HTML
      <div class="product">
        <a href="/test/" class="woocommerce-LoopProduct-link">
          <h2 class="woocommerce-loop-product__title">Test Product</h2>
          <img src="https://example.com/product.jpg" alt="Product">
        </a>
      </div>
    HTML
    element = Nokogiri::HTML(html_with_real_image).at_css(".product")

    data = @service.send(:extract_product_data, element)
    assert_equal "https://example.com/product.jpg", data[:image_url]
  end

  # Coverage for L90: any_price&.text&.strip (when any_price is nil)
  test "extract_price_text should return nil when no price elements found" do
    html_without_price = '<div class="product"><h2>Test Product</h2></div>'
    element = Nokogiri::HTML(html_without_price)

    price_text = @service.send(:extract_price_text, element)
    assert_nil price_text
  end

  test "extract_price_text should use fallback price element" do
    html_with_fallback_price = <<~HTML
      <div class="product">
        <div class="price">$299.99</div>
      </div>
    HTML
    element = Nokogiri::HTML(html_with_fallback_price)

    price_text = @service.send(:extract_price_text, element)
    assert_equal "$299.99", price_text
  end

  # Coverage for L108: return nil unless slug (when slug is nil)
  test "find_or_create_product should return nil when slug extraction fails" do
    product_data = {
      title: "Test Product",
      url: "http://[invalid-url]",
      price: 99.99
    }

    result = @service.send(:find_or_create_product, product_data)
    assert_nil result
  end
end
