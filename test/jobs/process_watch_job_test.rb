require "test_helper"

class ProcessWatchJobTest < ActiveJob::TestCase
  setup do
    @watch = watches(:one)
  end

  test "should process watch and update statistics" do
    # Mock the scraper service
    mock_scraper = mock("ProductScraperService")
    mock_products = [ mock("Product"), mock("Product") ]

    ProductScraperService.expects(:new).with(
      omit_terms: @watch.omit_terms_array,
      exclude_bundles: @watch.exclude_bundles
    ).returns(mock_scraper)

    mock_scraper.expects(:scrape).with(@watch.url).returns(mock_products)
    @watch.expects(:record_scrape_attempt).with(2)

    # Assert that the job runs without error
    assert_nothing_raised do
      ProcessWatchJob.perform_now(@watch)
    end
  end

  test "should handle scraper service errors gracefully" do
    # Mock the scraper service to raise an error
    ProductScraperService.expects(:new).with(
      omit_terms: @watch.omit_terms_array,
      exclude_bundles: @watch.exclude_bundles
    ).raises(StandardError.new("Network error"))

    @watch.expects(:record_scrape_attempt).with(0)

    assert_raises(StandardError) do
      ProcessWatchJob.perform_now(@watch)
    end
  end

  test "should handle watch record_scrape_attempt errors" do
    # Mock successful scraping but failing update
    mock_scraper = mock("ProductScraperService")
    mock_products = [ mock("Product") ]

    ProductScraperService.expects(:new).with(
      omit_terms: @watch.omit_terms_array,
      exclude_bundles: @watch.exclude_bundles
    ).returns(mock_scraper)
    mock_scraper.expects(:scrape).with(@watch.url).returns(mock_products)

    # First call fails, then rescue block calls it again with 0
    @watch.expects(:record_scrape_attempt).with(1).raises(ActiveRecord::RecordInvalid.new(@watch))
    @watch.expects(:record_scrape_attempt).with(0)

    assert_raises(ActiveRecord::RecordInvalid) do
      ProcessWatchJob.perform_now(@watch)
    end
  end

  test "should handle nil products from scraper" do
    mock_scraper = mock("ProductScraperService")

    ProductScraperService.expects(:new).with(
      omit_terms: @watch.omit_terms_array,
      exclude_bundles: @watch.exclude_bundles
    ).returns(mock_scraper)
    mock_scraper.expects(:scrape).with(@watch.url).returns(nil)

    @watch.expects(:record_scrape_attempt).with(0)

    assert_raises(NoMethodError) do
      ProcessWatchJob.perform_now(@watch)
    end
  end

  test "should handle empty products array from scraper" do
    mock_scraper = mock("ProductScraperService")

    ProductScraperService.expects(:new).with(
      omit_terms: @watch.omit_terms_array,
      exclude_bundles: @watch.exclude_bundles
    ).returns(mock_scraper)
    mock_scraper.expects(:scrape).with(@watch.url).returns([])
    @watch.expects(:record_scrape_attempt).with(0)

    assert_nothing_raised do
      ProcessWatchJob.perform_now(@watch)
    end
  end

  test "should skip processing for inactive watches" do
    @watch.active = false

    # Should not call scraper service for inactive watches
    ProductScraperService.expects(:new).never
    @watch.expects(:record_scrape_attempt).never

    assert_nothing_raised do
      ProcessWatchJob.perform_now(@watch)
    end
  end
end
