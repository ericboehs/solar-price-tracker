class ProductsController < ApplicationController
  def index
    @products = Product.all.order(created_at: :desc)
    @products = @products.limit(50) # Limit to prevent performance issues
  end

  def show
    @product = Product.find_by!(slug: params[:slug])
  end
end
