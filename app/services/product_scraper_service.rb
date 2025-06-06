require 'nokogiri'
require 'open-uri'

class ProductScraperService
  BASE_URL = "https://signaturesolar.com"
  
  def initialize(search_url)
    @search_url = search_url
  end
  
  def scrape_products
    products = []
    
    begin
      doc = fetch_document(@search_url)
      
      # Try multiple possible selectors for product cards
      selectors = [
        '.product-card',
        '.card',
        '.product-item',
        '.item',
        'article',
        '.listitem'
      ]
      
      product_cards = nil
      selectors.each do |selector|
        elements = doc.css(selector)
        if elements.length > 0
          product_cards = elements
          Rails.logger.info "Found #{elements.length} products using selector: #{selector}"
          break
        end
      end
      
      return [] unless product_cards
      
      product_cards.each do |card|
        product_data = extract_product_data(card)
        next unless product_data[:title] && product_data[:price]
        
        # Skip bundles - user doesn't want these
        next if bundle_product?(card, product_data)
        
        products << product_data
      end
      
    rescue => e
      Rails.logger.error "Error scraping products: #{e.message}"
      return []
    end
    
    products
  end
  
  def scrape_and_save_products
    products_data = scrape_products
    saved_count = 0
    price_changes_count = 0
    
    products_data.each do |product_data|
      # Extract slug from URL for deduplication
      slug = extract_slug_from_url(product_data[:url])
      next unless slug.present?
      
      product = Product.find_or_initialize_by(slug: slug)
      
      # Set basic attributes
      product.assign_attributes(
        title: product_data[:title],
        image_url: product_data[:image_url],
        url: product_data[:url]
      )
      
      # Handle price separately for historical tracking
      if product.persisted?
        # Existing product - check for price changes
        if product.record_price(product_data[:price])
          price_changes_count += 1
          Rails.logger.info "Price change detected for #{product.title}: #{product.price} -> #{product_data[:price]}"
        end
      else
        # New product - set initial price
        product.price = product_data[:price]
      end
      
      if product.save
        # Create initial price history record for new products
        unless product.price_histories.exists?
          product.record_price(product_data[:price])
        end
        saved_count += 1
      else
        Rails.logger.warn "Failed to save product: #{product.errors.full_messages}"
      end
    end
    
    Rails.logger.info "Scraped and saved #{saved_count} products with #{price_changes_count} price changes"
    { saved: saved_count, price_changes: price_changes_count }
  end
  
  private
  
  def fetch_document(url)
    html = URI.open(url, {
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
    })
    Nokogiri::HTML(html)
  end
  
  def extract_product_data(card)
    # Try multiple selectors for title
    title_selectors = ['h4.product-title a', '.product-title a', 'h4 a', 'h3 a', 'h2 a', '.title a', 'a[href*="product"]']
    title_element = nil
    title_selectors.each do |selector|
      element = card.css(selector).first
      if element && !element.text.strip.empty?
        title_element = element
        break
      end
    end
    
    # Try multiple selectors for price, prioritizing sale price and avoiding non-sale price
    sale_price_selectors = [
      '.sale-price--withoutTax',
      '.sale-price span', 
      '.sale-price .current-price', 
      '.price .sale-price',
      '.current-price',
      '[data-test-info="price-current"]'
    ]
    
    price_element = nil
    
    # First try to find explicit sale price elements
    sale_price_selectors.each do |selector|
      element = card.css(selector).first
      if element && !element.text.strip.empty?
        price_element = element
        break
      end
    end
    
    # If no explicit sale price found, look for any price elements but exclude non-sale ones
    unless price_element
      all_price_elements = card.css('.price, .product-pricing, [class*="price"]')
      
      # Filter out elements with 'non-sale' in their class
      sale_price_elements = all_price_elements.reject do |element|
        class_attr = element['class'] || ''
        class_attr.include?('non-sale')
      end
      
      # Find elements that contain actual price text
      price_elements_with_text = sale_price_elements.select do |element|
        element.text.strip.match(/\$[\d,]+/)
      end
      
      if price_elements_with_text.length > 0
        if price_elements_with_text.length > 1
          # Find the element with the lowest price
          prices_with_elements = price_elements_with_text.map do |element|
            price_val = extract_price_value(element.text)
            { element: element, price: price_val }
          end.compact
          
          if prices_with_elements.length > 0
            min_price_data = prices_with_elements.min_by { |data| data[:price] }
            price_element = min_price_data[:element]
          end
        else
          price_element = price_elements_with_text.first
        end
      end
    end
    
    # Try multiple selectors for image
    image_selectors = ['.product-image', 'img', '.image img', '.thumbnail img']
    image_element = nil
    image_selectors.each do |selector|
      element = card.css(selector).first
      if element && element['src']
        image_element = element
        break
      end
    end
    
    title = title_element&.text&.strip
    url = title_element&.[]('href')
    price_text = price_element&.text&.strip
    image_url = image_element&.[]('src')
    
    # Clean up the URL to be absolute
    url = "#{BASE_URL}#{url}" if url&.start_with?('/')
    
    # Clean up image URL to be absolute
    image_url = "#{BASE_URL}#{image_url}" if image_url&.start_with?('/')
    
    # Extract numeric price from price text
    price = extract_price(price_text)
    
    {
      title: title,
      price: price,
      image_url: image_url,
      url: url
    }
  end
  
  def extract_price(price_text)
    return nil unless price_text
    
    # Extract all prices from the text
    prices = price_text.scan(/\$?([\d,]+\.?\d*)/).map { |match| match[0].gsub(',', '').to_f }
    return nil if prices.empty?
    
    # If multiple prices found, return the lowest one (sale price)
    prices.min
  end
  
  def extract_price_value(text)
    return nil unless text
    match = text.match(/\$?([\d,]+\.?\d*)/)
    return nil unless match
    match[1].gsub(',', '').to_f
  end
  
  def extract_slug_from_url(url)
    return nil if url.blank?
    
    begin
      uri = URI.parse(url)
      path = uri.path
      slug = path.split('/').last.split('?').first
      
      # Clean the slug
      slug = slug.gsub(/[^a-z0-9\-]/, '').strip
      
      slug.present? ? slug : nil
    rescue URI::InvalidURIError
      nil
    end
  end
  
  def bundle_product?(card, product_data)
    title = product_data[:title]
    return false unless title
    
    # Check for bundle indicators in title
    return true if title.downcase.include?('bundle')
    return true if title.include?('BNDL-')
    
    # Check for "Options" button (bundles have Options instead of Add to Cart)
    options_button = card.css('button, .button, .btn').find do |btn|
      btn.text.strip.downcase.include?('option')
    end
    
    return true if options_button
    
    false
  end
end