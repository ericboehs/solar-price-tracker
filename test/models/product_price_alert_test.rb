require "test_helper"

class ProductPriceAlertTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup { @product = products(:battery_48v) } # history: 1299.99 then 1199.99

  test "a new historical low enqueues a price drop alert" do
    assert_enqueued_with(job: PriceDropAlertJob,
      args: [ @product, { previous_low: BigDecimal("1199.99"), previous_price: BigDecimal("1199.99") } ]) do
      @product.record_price_change(BigDecimal("1099.99"))
    end
  end

  test "a drop that is not below the historical low does not alert" do
    @product.record_price_change(BigDecimal("1399.99"))
    assert_no_enqueued_jobs(only: PriceDropAlertJob) do
      @product.record_price_change(BigDecimal("1249.99"))
    end
  end

  test "matching the historical low (within a cent) does not alert" do
    @product.record_price_change(BigDecimal("1399.99"))
    assert_no_enqueued_jobs(only: PriceDropAlertJob) do
      @product.record_price_change(BigDecimal("1199.99"))
    end
  end

  test "the first recorded price does not alert" do
    product = Product.create!(title: "New thing", url: "https://signaturesolar.com/new-thing/", price: 10)
    assert_no_enqueued_jobs(only: PriceDropAlertJob) do
      product.record_price_change(BigDecimal("10"))
    end
  end
end
