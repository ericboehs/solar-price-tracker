require "nokogiri"
require "open-uri"

class ProductScraperService
  BASE_URL = "https://signaturesolar.com"
  USER_AGENT = "Mozilla/5.0 (compatible; SolarPriceTracker/1.0; +https://github.com/ericboehs/solar-price-tracker)"
  MAX_PAGES = 10
  PAGE_DELAY = 1.0 # seconds between paginated requests
  IMAGE_SIZE = "608x608"

  def initialize(search_url = nil, debug: false, exclude_bundles: true, omit_terms: [], max_pages: MAX_PAGES, page_delay: PAGE_DELAY)
    @search_url = search_url
    @scraped_products = []
    @debug = debug
    @exclude_bundles = exclude_bundles
    @omit_terms = Array(omit_terms).map(&:downcase)
    @max_pages = max_pages
    @page_delay = page_delay
  end

  def scrape(url = nil)
    url ||= @search_url
    raise ArgumentError, "No URL provided" unless url

    visited = Set.new
    while url && visited.size < @max_pages && visited.add?(url)
      debug_log "Fetching page #{visited.size}: #{url}"
      page = fetch_page(url)
      break unless page

      scrape_page(page)
      url = next_page_url(page)
      sleep(@page_delay) if url && @page_delay.positive?
    end

    @scraped_products.uniq!
    debug_log "Successfully scraped #{@scraped_products.length} products"
    @scraped_products
  end

  def debug_scrape
    @debug = true
    scrape
  end

  private

  def scrape_page(page)
    debug_log "Page fetched successfully, title: #{page.title}"

    product_data_list = extract_products(page)
    debug_log "Extracted #{product_data_list.length} product data entries"

    product_data_list.each_with_index do |product_data, index|
      debug_log "Processing product #{index + 1}: #{product_data[:title]}"
      product = find_or_create_product(product_data)
      @scraped_products << product if product
    end
  end

  # Follows BigCommerce pagination (<link rel="next"> or the pagination widget),
  # staying on signaturesolar.com.
  def next_page_url(page)
    href = page.at_css("link[rel=next], .pagination-item--next a, a[rel=next]")&.[]("href")
    return nil if href.blank?

    next_url = URI.join(BASE_URL, href).to_s
    next_url.start_with?(BASE_URL) ? next_url : nil
  rescue URI::InvalidURIError
    nil
  end

  def fetch_page(url)
    URI.open(url, "User-Agent" => USER_AGENT, open_timeout: 15, read_timeout: 30) do |page|
      Nokogiri::HTML(page)
    end
  rescue OpenURI::HTTPError, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error "Failed to fetch page #{url}: #{e.message}"
    nil
  end

  def extract_products(page)
    products = []

    # Updated selectors for SignatureSolar.com BigCommerce structure
    selectors = [ ".card", ".product", ".product-item", ".woocommerce ul.products li.product" ]

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
            # Check if product contains any omit terms
            elsif should_omit_product?(product_data[:title])
              debug_log "    ✗ Skipped due to omit terms: #{product_data[:title]}"
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

    # Extract title - updated for SignatureSolar BigCommerce structure
    title_element = element.at_css("h4.card-title a, .card-title, h4, .woocommerce-loop-product__title, h3 a, h2 a, .product-title a, .product-name a")
    data[:title] = title_element&.text&.strip

    # Extract URL - updated for SignatureSolar BigCommerce structure
    link_element = element.at_css("h4.card-title a, a[href*='eg4'], a[href*='product'], a.woocommerce-LoopProduct-link, h3 a, h2 a, .product-title a, .product-name a")
    if link_element
      href = link_element["href"]
      data[:url] = clean_product_url(href.start_with?("http") ? href : "#{BASE_URL}#{href}")
    end

    # Extract price (prioritize sale price)
    price_text = extract_price_text(element)
    data[:price] = parse_price(price_text) if price_text

    # Extract image URL - updated for SignatureSolar BigCommerce structure
    img_element = element.at_css(".card-image, img")
    if img_element
      src = img_element["src"] || img_element["data-src"]
      data[:image_url] = upsize_image_url(src) if src && !src.include?("placeholder")
    end

    data
  end

  def extract_price_text(element)
    # Updated price selectors for SignatureSolar BigCommerce structure
    price_selectors = [
      "span[data-product-price-without-tax]",     # Primary price selector for SignatureSolar
      "span[data-product-sale-price-without-tax]", # Sale price if available
      ".price ins .woocommerce-Price-amount",     # WooCommerce sale price
      ".price .woocommerce-Price-amount",         # WooCommerce regular price
      ".price",                                   # Generic price element
      ".card-price",                              # BigCommerce card price
      ".money",                                   # Generic money element
      "[data-test-id*='price']"                   # Data attribute price
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
    scraped_at = Time.current

    if product
      # Update existing product and record price history if changed
      old_price = product.price
      product.update(
        title: product_data[:title],
        url: product_data[:url],
        price: product_data[:price],
        image_url: product_data[:image_url],
        last_scraped_at: scraped_at
      )

      # Record price change if price is different
      if old_price != product_data[:price]
        product.record_price_change(product_data[:price], scraped_at)
        debug_log "    Price changed from $#{old_price} to $#{product_data[:price]}"
      end
    else
      # Create new product
      product = Product.create(
        title: product_data[:title],
        url: product_data[:url],
        slug: slug,
        price: product_data[:price],
        image_url: product_data[:image_url],
        last_scraped_at: scraped_at
      )

      # Record initial price history for new products
      if product.persisted?
        product.record_price_change(product_data[:price], scraped_at)
        debug_log "    Recorded initial price: $#{product_data[:price]}"
      end
    end

    product.persisted? ? product : nil
  end

  # Drop per-search tracking params (e.g. ?searchuuid=...&search_query=...).
  def clean_product_url(url)
    uri = URI.parse(url)
    uri.query = nil
    uri.fragment = nil
    uri.to_s
  rescue URI::InvalidURIError
    url
  end

  # BigCommerce serves resized images at /images/stencil/WxH/; ask for a larger one.
  def upsize_image_url(src)
    src.sub(%r{/images/stencil/(?:\d+x\d+|\d+w)/}, "/images/stencil/#{IMAGE_SIZE}/")
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
    bundle_keywords.any? { |keyword| title_lower.match?(/\b#{Regexp.escape(keyword)}s?\b/) }
  end

  def should_omit_product?(title)
    return false if @omit_terms.empty? || title.blank?

    title_lower = title.downcase
    @omit_terms.any? { |term| title_lower.include?(term) }
  end
end
