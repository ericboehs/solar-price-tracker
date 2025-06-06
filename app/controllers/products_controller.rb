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
end
