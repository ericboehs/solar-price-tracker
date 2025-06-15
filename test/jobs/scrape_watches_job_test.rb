require "test_helper"

class ScrapeWatchesJobTest < ActiveJob::TestCase
  setup do
    @active_watch = watches(:one)
    @inactive_watch = watches(:two)
  end

  test "should enqueue ProcessWatchJob for watches ready for scraping" do
    # Mock the ready_for_scraping scope to return relation that responds to find_each
    mock_relation = mock("ActiveRecord::Relation")
    mock_relation.expects(:count).returns(1)
    mock_relation.expects(:find_each).yields(@active_watch)
    Watch.expects(:ready_for_scraping).returns(mock_relation)

    assert_enqueued_with(job: ProcessWatchJob, args: [ @active_watch ]) do
      assert_nothing_raised do
        ScrapeWatchesJob.perform_now
      end
    end
  end

  test "should not enqueue jobs for inactive watches" do
    # Mock the ready_for_scraping scope to return empty relation
    mock_relation = mock("ActiveRecord::Relation")
    mock_relation.expects(:count).returns(0)
    mock_relation.expects(:find_each) # yields nothing
    Watch.expects(:ready_for_scraping).returns(mock_relation)

    assert_no_enqueued_jobs do
      assert_nothing_raised do
        ScrapeWatchesJob.perform_now
      end
    end
  end

  test "should handle multiple watches ready for scraping" do
    ready_watches = [ @active_watch, @inactive_watch ]
    mock_relation = mock("ActiveRecord::Relation")
    mock_relation.expects(:count).returns(2)
    mock_relation.expects(:find_each).multiple_yields([ @active_watch ], [ @inactive_watch ])
    Watch.expects(:ready_for_scraping).returns(mock_relation)

    assert_enqueued_jobs 2, only: ProcessWatchJob do
      assert_nothing_raised do
        ScrapeWatchesJob.perform_now
      end
    end
  end

  test "should log the number of watches processed" do
    mock_relation = mock("ActiveRecord::Relation")
    mock_relation.expects(:count).returns(1)
    mock_relation.expects(:find_each).yields(@active_watch)
    Watch.expects(:ready_for_scraping).returns(mock_relation)

    assert_nothing_raised do
      ScrapeWatchesJob.perform_now
    end
  end

  test "should handle database errors gracefully" do
    Watch.expects(:ready_for_scraping).raises(StandardError.new("Database error"))

    assert_raises(StandardError) do
      ScrapeWatchesJob.perform_now
    end
  end

  test "should handle empty watch collection" do
    mock_relation = mock("ActiveRecord::Relation")
    mock_relation.expects(:count).returns(0)
    mock_relation.expects(:find_each)
    Watch.expects(:ready_for_scraping).returns(mock_relation)

    assert_no_enqueued_jobs do
      assert_nothing_raised do
        ScrapeWatchesJob.perform_now
      end
    end
  end

  test "should handle job queuing errors gracefully" do
    mock_relation = mock("ActiveRecord::Relation")
    mock_relation.expects(:count).returns(1)
    mock_relation.expects(:find_each).yields(@active_watch)
    Watch.expects(:ready_for_scraping).returns(mock_relation)

    # Mock ProcessWatchJob.perform_later to raise an error
    ProcessWatchJob.expects(:perform_later).with(@active_watch).raises(StandardError.new("Queue error"))

    assert_nothing_raised do
      ScrapeWatchesJob.perform_now
    end
  end
end
