require "nokogiri"
require "open-uri"

class ProductScraperService
  BASE_URL = "https://signaturesolar.com"

  def initialize(search_url)
    @search_url = search_url
    @scraped_products = []
  end

  def scrape
    page = fetch_page(@search_url)
    return [] unless page

    extract_products(page).each do |product_data|
      product = find_or_create_product(product_data)
      @scraped_products << product if product
    end

    @scraped_products
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

    # SignatureSolar product grid items
    page.css(".product-item, .product, .woocommerce ul.products li.product").each do |product_element|
      product_data = extract_product_data(product_element)
      # Only include products with valid data and SignatureSolar URLs
      if product_data[:url] && product_data[:title] && product_data[:price] &&
        product_data[:url].include?("signaturesolar.com")
        products << product_data
      end
    end

    products
  end

  def extract_product_data(element)
    data = {}

    # Extract title with multiple selector fallbacks
    title_element = element.at_css(".woocommerce-loop-product__title, h3 a, h2 a, .product-title a, .product-name a")
    data[:title] = title_element&.text&.strip

    # Extract URL
    link_element = element.at_css("a.woocommerce-LoopProduct-link, h3 a, h2 a, .product-title a, .product-name a")
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
    # Try sale price first (inside <ins> tag)
    sale_price = element.at_css(".price ins .woocommerce-Price-amount, .sale-price")
    return sale_price.text.strip if sale_price

    # Fall back to regular price
    regular_price = element.at_css(".price .woocommerce-Price-amount, .regular-price")
    return regular_price.text.strip if regular_price

    # Last fallback - any price element
    any_price = element.at_css(".price")
    any_price&.text&.strip
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
end
