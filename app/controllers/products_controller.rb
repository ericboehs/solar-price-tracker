class ProductsController < ApplicationController
  def index
    @products = Product.includes(:price_histories).order(created_at: :desc)
    @products = @products.limit(50) # Limit to prevent performance issues
  end

  def show
    @product = Product.find_by!(slug: params[:slug])
    @price_histories = @product.price_histories.ordered.limit(100) # Last 100 price points
  end
end
