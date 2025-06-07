require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get show" do
    product = products(:one)
    get product_url(product)
    assert_response :success
  end

  test "index renders with price histories" do
    product = products(:one)
    product.price_histories.create!(price: 100.00, recorded_at: 8.days.ago)
    product.price_histories.create!(price: 110.00, recorded_at: 1.day.ago)

    get products_url
    assert_response :success
  end

  test "index handles no price changes gracefully" do
    # Clear all price histories
    PriceHistory.delete_all

    get products_url
    assert_response :success
  end

  test "show renders with price data" do
    product = products(:one)
    product.price_histories.create!(price: 100.00, recorded_at: 2.days.ago)
    product.price_histories.create!(price: 110.00, recorded_at: 1.day.ago)

    get product_url(product)
    assert_response :success
  end

  test "show returns 404 for non-existent product" do
    get product_url(id: 999999)
    assert_response :not_found
  rescue ActiveRecord::RecordNotFound
    # This is expected behavior
    assert true
  end

  test "allows unauthenticated access to index" do
    get products_url
    assert_response :success
  end

  test "allows unauthenticated access to show" do
    product = products(:one)
    get product_url(product)
    assert_response :success
  end
end
