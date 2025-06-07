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

  test "scrape_products returns empty array when no products found" do
    empty_doc = Nokogiri::HTML("<html><body><div class='no-products'>No products found</div></body></html>")
    @service.expects(:fetch_document).returns(empty_doc)
    products = @service.scrape_products
    assert_equal [], products
  end

  test "scrape_products extracts products from listing page" do
    html = "<html><body><div class='product-card'><h4 class='product-title'><a href='/products/test-battery'>Test Battery</a></h4><div class='price'><span class='sale-price--withoutTax'>$999.99</span></div><img class='product-image' src='/image.jpg'></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    products = @service.scrape_products
    assert_equal 1, products.length
    assert_equal "Test Battery", products.first[:title]
    assert_equal 999.99, products.first[:price]
  end

  test "extract_product_data extracts all product information" do
    card_html = "<div class='product-card'><h4 class='product-title'><a href='/products/test-battery'>Test Battery</a></h4><div class='price'><span class='sale-price--withoutTax'>$999.99</span></div><img class='product-image' src='/image.jpg'></div>"
    card = Nokogiri::HTML::DocumentFragment.parse(card_html).children.first
    
    result = @service.send(:extract_product_data, card)
    
    assert_equal "Test Battery", result[:title]
    assert_equal 999.99, result[:price]
    assert_equal "https://signaturesolar.com/products/test-battery", result[:url]
    assert_equal "https://signaturesolar.com/image.jpg", result[:image_url]
  end

  test "extract_product_data handles missing elements" do
    card_html = "<div class='product-card'></div>"
    card = Nokogiri::HTML::DocumentFragment.parse(card_html).children.first
    
    result = @service.send(:extract_product_data, card)
    
    assert_nil result[:title]
    assert_nil result[:price]
    assert_nil result[:url]
    assert_nil result[:image_url]
  end

  test "extract_product_data chooses lowest price from multiple elements" do
    card_html = "<div class='product-card'><h4 class='product-title'><a href='/test'>Test</a></h4><div class='price'>$200.00</div><div class='price'>$150.00</div><div class='price'>$180.00</div></div>"
    card = Nokogiri::HTML::DocumentFragment.parse(card_html).children.first
    
    result = @service.send(:extract_product_data, card)
    assert_equal 150.0, result[:price]
  end

  test "extract_product_data filters out non-sale prices" do
    card_html = "<div class='product-card'><h4 class='product-title'><a href='/test'>Test</a></h4><div class='price non-sale-price'>$300.00</div><div class='price sale-price'>$200.00</div></div>"
    card = Nokogiri::HTML::DocumentFragment.parse(card_html).children.first
    
    result = @service.send(:extract_product_data, card)
    assert_equal 200.0, result[:price]
  end

  test "extract_single_product_data extracts from product detail page" do
    html = "<html><body><div class='product-details'><h1 class='product-title'>Single Product</h1><div class='price--main'><span class='price--withoutTax'>$1500.00</span></div><div class='productView-image-main'><img src='/single.jpg'></div></div></body></html>"
    doc = Nokogiri::HTML(html)
    
    result = @service.send(:extract_single_product_data, doc)
    
    assert_equal "Single Product", result[:title]
    assert_equal 1500.0, result[:price]
    assert_equal "https://signaturesolar.com/single.jpg", result[:image_url]
    assert_equal "https://example.com", result[:url]
  end

  test "extract_single_product_data handles meta tags" do
    html = "<html><head><meta property='og:title' content='Meta Product'><meta property='product:price:amount' content='2000.00'><meta property='og:image' content='/meta.jpg'></head><body><div class='product-details'></div></body></html>"
    doc = Nokogiri::HTML(html)
    
    result = @service.send(:extract_single_product_data, doc)
    
    assert_equal "Meta Product", result[:title]
    assert_equal 2000.0, result[:price]
    assert_equal "https://signaturesolar.com/meta.jpg", result[:image_url]
  end

  test "scrape_and_save_products creates new products" do
    html = "<html><body><div class='product-card'><h4 class='product-title'><a href='/products/new-test-battery'>New Test Battery</a></h4><div class='price'><span class='sale-price--withoutTax'>$1299.99</span></div></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    assert_difference "Product.count", 1 do
      result = @service.scrape_and_save_products
      assert_equal 1, result[:saved]
      assert_equal 0, result[:price_changes]
    end
  end

  test "scrape_and_save_products detects price changes" do
    # Create existing product
    product = products(:one)
    product.update!(slug: "new-test-battery", price: 800.0, url: "https://example.com/test")
    
    html = "<html><body><div class='product-card'><h4 class='product-title'><a href='/products/new-test-battery'>New Test Battery</a></h4><div class='price'><span class='sale-price--withoutTax'>$1299.99</span></div></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    result = @service.scrape_and_save_products
    assert_equal 1, result[:saved]
    assert_equal 1, result[:price_changes]
    
    product.reload
    assert_equal 1299.99, product.price
  end

  test "scrape_and_save_products creates price history for new products" do
    html = "<html><body><div class='product-card'><h4 class='product-title'><a href='/products/unique-battery-#{Time.current.to_i}'>Unique Battery</a></h4><div class='price'><span class='sale-price--withoutTax'>$999.99</span></div></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    assert_difference "PriceHistory.count", 1 do
      @service.scrape_and_save_products
    end
  end

  test "scrape_and_save_products skips products without valid slugs" do
    html = "<html><body><div class='product-card'><h4 class='product-title'><a href=''>No URL Product</a></h4><div class='price'>$999.99</div></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    assert_no_difference "Product.count" do
      result = @service.scrape_and_save_products
      assert_equal 0, result[:saved]
    end
  end

  test "scrape_and_save_products handles products with missing price" do
    html = "<html><body><div class='product-card'><h4 class='product-title'><a href='/products/no-price-battery'>No Price Battery</a></h4></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    assert_no_difference "Product.count" do
      result = @service.scrape_and_save_products
      assert_equal 0, result[:saved]
    end
  end

  test "scrape_and_save_products handles products with missing title" do
    html = "<html><body><div class='product-card'><div class='price'>$999.99</div></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    assert_no_difference "Product.count" do
      result = @service.scrape_and_save_products
      assert_equal 0, result[:saved]
    end
  end

  test "scrape_products filters out bundles by title" do
    html = "<html><body><div class='product-card'><h4 class='product-title'><a href='/products/battery-bundle'>Battery Bundle</a></h4><div class='price'>$999.99</div></div><div class='product-card'><h4 class='product-title'><a href='/products/regular-battery'>Regular Battery</a></h4><div class='price'>$799.99</div></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    products = @service.scrape_products
    assert_equal 1, products.length
    assert_equal "Regular Battery", products.first[:title]
  end

  test "scrape_products filters out bundles by BNDL prefix" do
    html = "<html><body><div class='product-card'><h4 class='product-title'><a href='/products/bndl-123'>BNDL-123 Special</a></h4><div class='price'>$999.99</div></div><div class='product-card'><h4 class='product-title'><a href='/products/regular-battery'>Regular Battery</a></h4><div class='price'>$799.99</div></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    products = @service.scrape_products
    assert_equal 1, products.length
    assert_equal "Regular Battery", products.first[:title]
  end

  test "scrape_products filters out bundles by options button" do
    html = "<html><body><div class='product-card'><h4 class='product-title'><a href='/products/test1'>Test Product 1</a></h4><div class='price'>$999.99</div><button>View Options</button></div><div class='product-card'><h4 class='product-title'><a href='/products/test2'>Test Product 2</a></h4><div class='price'>$799.99</div><button>Add to Cart</button></div></body></html>"
    doc = Nokogiri::HTML(html)
    @service.expects(:fetch_document).returns(doc)
    
    products = @service.scrape_products
    assert_equal 1, products.length
    assert_equal "Test Product 2", products.first[:title]
  end
end
