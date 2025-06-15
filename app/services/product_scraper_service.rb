require "nokogiri"
require "open-uri"

class ProductScraperService
  BASE_URL = "https://signaturesolar.com"

  def initialize(search_url, debug: false, exclude_bundles: true)
    @search_url = search_url
    @scraped_products = []
    @debug = debug
    @exclude_bundles = exclude_bundles
  end

  def scrape
    debug_log "Starting scrape of: #{@search_url}"
    page = fetch_page(@search_url)
    return [] unless page

    debug_log "Page fetched successfully, title: #{page.title}"

    product_data_list = extract_products(page)
    debug_log "Extracted #{product_data_list.length} product data entries"

    product_data_list.each_with_index do |product_data, index|
      debug_log "Processing product #{index + 1}: #{product_data[:title]}"
      product = find_or_create_product(product_data)
      @scraped_products << product if product
    end

    debug_log "Successfully scraped #{@scraped_products.length} products"
    @scraped_products
  end

  def debug_scrape
    @debug = true
    scrape
  end

  private

  def fetch_page(url)
    URI.open(url) do |page|
      Nokogiri::HTML(page)
    end
  rescue OpenURI::HTTPError, SocketError => e
    Rails.logger.error "Failed to fetch page #{url}: #{e.message}"
    nil
  end

  def extract_products(page)
    products = []

    # Try multiple selectors for different site structures
    selectors = [ ".product", ".product-item", ".woocommerce ul.products li.product" ]

    selectors.each do |selector|
      elements = page.css(selector)
      debug_log "Trying selector '#{selector}': found #{elements.length} elements"

      if elements.any?
        elements.each_with_index do |product_element, index|
          product_data = extract_product_data(product_element)
          debug_log "  Product #{index + 1} data: #{product_data.inspect}"

          # Only include products with valid data and SignatureSolar URLs
          if product_data[:url] && product_data[:title] && product_data[:price] &&
            product_data[:url].include?("signaturesolar.com")

            # Check if we should exclude bundles/kits
            if @exclude_bundles && is_bundle_or_kit?(product_data[:title])
              debug_log "    ✗ Skipped bundle/kit: #{product_data[:title]}"
            else
              products << product_data
              debug_log "    ✓ Added valid product: #{product_data[:title]}"
            end
          else
            debug_log "    ✗ Skipped invalid product - URL: #{!!product_data[:url]}, Title: #{!!product_data[:title]}, Price: #{!!product_data[:price]}"
          end
        end
        break if products.any? # Use the first selector that finds products
      end
    end

    products
  end

  def extract_product_data(element)
    data = {}

    # Extract title with multiple selector fallbacks (updated for BigCommerce)
    title_element = element.at_css(".card-title, h4, .woocommerce-loop-product__title, h3 a, h2 a, .product-title a, .product-name a")
    data[:title] = title_element&.text&.strip

    # Extract URL (updated for BigCommerce)
    link_element = element.at_css("a[href*='eg4'], a[href*='product'], a.woocommerce-LoopProduct-link, h3 a, h2 a, .product-title a, .product-name a")
    if link_element
      href = link_element["href"]
      data[:url] = href.start_with?("http") ? href : "#{BASE_URL}#{href}"
    end

    # Extract price (prioritize sale price)
    price_text = extract_price_text(element)
    data[:price] = parse_price(price_text) if price_text

    # Extract image URL
    img_element = element.at_css("img")
    if img_element
      src = img_element["src"] || img_element["data-src"]
      data[:image_url] = src if src && !src.include?("placeholder")
    end

    data
  end

  def extract_price_text(element)
    # Try BigCommerce price structure first
    price_selectors = [
      ".price ins .woocommerce-Price-amount", # WooCommerce sale price
      ".price .woocommerce-Price-amount",     # WooCommerce regular price
      ".price",                               # Generic price element
      ".card-price",                          # BigCommerce card price
      ".money",                               # Generic money element
      "[data-test-id*='price']"               # Data attribute price
    ]

    price_selectors.each do |selector|
      price_element = element.at_css(selector)
      if price_element
        text = price_element.text.strip
        debug_log "    Found price with selector '#{selector}': '#{text}'"
        return text if text.present? && text.match?(/[\d\$]/)
      end
    end

    debug_log "    No price found with any selector"
    nil
  end

  def debug_log(message)
    puts message if @debug
  end

  def parse_price(price_text)
    return nil unless price_text

    # Remove currency symbols and whitespace, extract numeric value
    cleaned = price_text.gsub(/[$,\s]/, "")
    Float(cleaned)
  rescue ArgumentError
    nil
  end

  def find_or_create_product(product_data)
    return nil unless product_data[:url]

    # Generate slug from URL for deduplication
    slug = extract_slug_from_url(product_data[:url])
    return nil unless slug

    product = Product.find_by(slug: slug)

    if product
      # Update existing product
      product.update(
        title: product_data[:title],
        price: product_data[:price],
        image_url: product_data[:image_url],
        last_scraped_at: Time.current
      )
    else
      # Create new product
      product = Product.create(
        title: product_data[:title],
        url: product_data[:url],
        slug: slug,
        price: product_data[:price],
        image_url: product_data[:image_url],
        last_scraped_at: Time.current
      )
    end

    product.persisted? ? product : nil
  end

  def extract_slug_from_url(url)
    uri = URI.parse(url)
    path_segments = uri.path.split("/").reject(&:blank?)
    path_segments.last
  rescue URI::InvalidURIError, ArgumentError
    nil
  end

  def is_bundle_or_kit?(title)
    return false unless title

    # Common bundle/kit indicators
    bundle_keywords = [
      "bundle", "kit", "system", "package", "combo", "set",
      "starter kit", "complete kit", "solar kit", "power kit",
      "off-grid kit", "grid-tie kit", "diy kit", "backup kit"
    ]

    title_lower = title.downcase
    bundle_keywords.any? { |keyword| title_lower.include?(keyword) }
  end
end
