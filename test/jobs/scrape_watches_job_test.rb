require "test_helper"

class ScrapeWatchesJobTest < ActiveJob::TestCase
  setup do
    @active_search_watch = Watch.create!(
      name: "Test Search Watch",
      url: "https://signaturesolar.com/test",
      active: true
    )

    @inactive_search_watch = Watch.create!(
      name: "Inactive Search Watch",
      url: "https://signaturesolar.com/inactive",
      active: false
    )
  end

  test "should skip inactive watches" do
    # Only inactive watch exists, so no scraping should occur
    @active_search_watch.destroy

    result = ScrapeWatchesJob.new.perform

    assert_equal 0, result[:total_saved]
    assert_equal 0, result[:total_price_changes]
  end

  test "should return results hash" do
    # Test with no active watches to avoid actual scraping
    @active_search_watch.destroy

    result = ScrapeWatchesJob.new.perform

    assert_kind_of Hash, result
    assert_includes result.keys, :total_saved
    assert_includes result.keys, :total_price_changes
  end

  test "should enqueue job when active search watch is created" do
    assert_enqueued_with(job: ScrapeWatchesJob) do
      Watch.create!(
        name: "New Search Watch",
        url: "https://signaturesolar.com/new",
        active: true
      )
    end
  end

  test "should not enqueue job when inactive watch is created" do
    assert_no_enqueued_jobs do
      Watch.create!(
        name: "New Inactive Watch",
        url: "https://signaturesolar.com/new",
        active: false
      )
    end
  end

  test "should process active watches and log information" do
    # Test that the job runs without errors and processes active watches
    assert_nothing_raised do
      result = ScrapeWatchesJob.new.perform
      assert_kind_of Hash, result
    end
  end
end
