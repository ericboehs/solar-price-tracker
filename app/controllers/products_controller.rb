class ProductsController < ApplicationController
  before_action :set_product, only: [:show]
  
  def index
    @products = Product.includes(:price_histories)
                      .order(:title)
    @total_products = @products.count
    @recent_changes = Product.joins(:price_histories)
                            .where(price_histories: { created_at: 24.hours.ago..Time.current })
                            .distinct
                            .count
    @last_scraping_run = Product.maximum(:last_scraped_at)
    @avg_weekly_change = calculate_average_weekly_change
  end

  def show
    @price_histories = @product.price_histories.recent.limit(30)
    @price_trend = @product.price_trend
    @price_change = @product.price_change_percentage
  end
  
  private
  
  def set_product
    @product = Product.find(params[:id])
  end
  
  def calculate_average_weekly_change
    products_with_weekly_data = @products.select do |product|
      product.price_change_percentage(7) # 7 days instead of default 30
    end
    
    return nil if products_with_weekly_data.empty?
    
    changes = products_with_weekly_data.map { |product| product.price_change_percentage(7) }.compact
    return nil if changes.empty?
    
    (changes.sum / changes.length).round(2)
  end
end
