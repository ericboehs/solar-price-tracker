require "test_helper"

class WatchTest < ActiveSupport::TestCase
  setup do
    @watch = watches(:one)
  end

  test "should be valid with valid attributes" do
    assert @watch.valid?
  end

  test "should require name" do
    @watch.name = nil
    assert_not @watch.valid?
    assert_includes @watch.errors[:name], "can't be blank"
  end

  test "should require name to be at least 3 characters" do
    @watch.name = "ab"
    assert_not @watch.valid?
    assert_includes @watch.errors[:name], "is too short (minimum is 3 characters)"
  end

  test "should require name to be at most 100 characters" do
    @watch.name = "a" * 101
    assert_not @watch.valid?
    assert_includes @watch.errors[:name], "is too long (maximum is 100 characters)"
  end

  test "should require url" do
    @watch.url = nil
    assert_not @watch.valid?
    assert_includes @watch.errors[:url], "can't be blank"
  end

  test "should require valid url format" do
    @watch.url = "invalid-url"
    assert_not @watch.valid?
    assert_includes @watch.errors[:url], "is invalid"
  end

  test "should accept valid urls" do
    valid_urls = [
      "https://example.com",
      "http://example.com/path",
      "https://example.com/path?query=value",
      "https://subdomain.example.com/path#anchor"
    ]

    valid_urls.each do |url|
      @watch.url = url
      assert @watch.valid?, "#{url} should be valid"
    end
  end

  test "should require watch_type to be in allowed values" do
    @watch.watch_type = "invalid"
    assert_not @watch.valid?
    assert_includes @watch.errors[:watch_type], "is not included in the list"
  end

  test "should accept valid watch_types" do
    Watch::WATCH_TYPES.each do |type|
      @watch.watch_type = type
      assert @watch.valid?, "#{type} should be valid"
    end
  end

  test "should have default values" do
    watch = Watch.new(
      name: "Test Watch",
      url: "https://example.com",
      watch_type: "search"
    )

    assert watch.active?
    assert watch.exclude_bundles?
    assert_equal 4, watch.scrape_frequency_hours # Search type has 4 hour frequency
    assert_equal 0, watch.scrape_count
    assert_equal 0, watch.products_found
  end

  test "should parse omit_terms correctly" do
    @watch.omit_terms = "term1,term2,term3"
    assert_equal [ "term1", "term2", "term3" ], @watch.omit_terms_array
  end

  test "should handle newline separated omit_terms" do
    @watch.omit_terms = "term1\nterm2\nterm3"
    assert_equal [ "term1", "term2", "term3" ], @watch.omit_terms_array
  end

  test "should handle mixed comma and newline omit_terms" do
    @watch.omit_terms = "term1,term2\nterm3,term4"
    assert_equal [ "term1", "term2", "term3", "term4" ], @watch.omit_terms_array
  end

  test "should handle empty omit_terms" do
    @watch.omit_terms = ""
    assert_equal [], @watch.omit_terms_array

    @watch.omit_terms = nil
    assert_equal [], @watch.omit_terms_array
  end

  test "should trim whitespace from omit_terms" do
    @watch.omit_terms = " term1 , term2 \n term3 "
    assert_equal [ "term1", "term2", "term3" ], @watch.omit_terms_array
  end

  test "display_name should return name when present" do
    assert_equal @watch.name, @watch.display_name
  end

  test "display_name should return truncated url when name is blank" do
    @watch.name = ""
    assert_equal "signaturesolar.com", @watch.display_name
  end

  test "should determine status correctly" do
    # Active and ready for scraping
    @watch.active = true
    @watch.next_scrape_at = 1.hour.ago
    assert_equal "ready", @watch.status

    # Active but recently scraped (next scrape in future + last_scraped_at present)
    @watch.next_scrape_at = 1.hour.from_now
    @watch.last_scraped_at = 30.minutes.ago # More recent than 1 hour ago
    assert_equal "recently_scraped", @watch.status

    # Active but scheduled for future (next_scrape_at in future + no last_scraped_at)
    @watch.last_scraped_at = nil
    @watch.next_scrape_at = 1.hour.from_now
    assert_equal "scheduled", @watch.status

    # Inactive
    @watch.active = false
    assert_equal "inactive", @watch.status
  end

  test "record_scrape_attempt should update statistics" do
    original_count = @watch.scrape_count
    original_time = @watch.last_scraped_at

    @watch.record_scrape_attempt(5)

    assert_equal original_count + 1, @watch.scrape_count
    assert_equal 5, @watch.products_found
    assert @watch.last_scraped_at > original_time
    assert @watch.next_scrape_at > Time.current
  end

  test "ready_for_scraping scope should return correct watches" do
    # Clear existing watches to avoid interference
    Watch.destroy_all

    travel_to Time.current do
      # Create watches with different states
      ready_watch = Watch.create!(
        name: "Ready Watch",
        url: "https://example.com/ready",
        watch_type: "search",
        active: true
      )
      ready_watch.update_column(:next_scrape_at, 1.hour.ago) # Force past time

      not_ready_watch = Watch.create!(
        name: "Not Ready Watch",
        url: "https://example.com/not-ready",
        watch_type: "search",
        active: true
      )
      not_ready_watch.update_column(:next_scrape_at, 1.hour.from_now) # Force future time

      inactive_watch = Watch.create!(
        name: "Inactive Watch",
        url: "https://example.com/inactive",
        watch_type: "search",
        active: false
      )

      ready_watches = Watch.ready_for_scraping

      assert_includes ready_watches, ready_watch
      assert_not_includes ready_watches, not_ready_watch
      assert_not_includes ready_watches, inactive_watch
    end
  end

  test "active scope should return only active watches" do
    active_watches = Watch.active

    active_watches.each do |watch|
      assert watch.active?, "Watch #{watch.id} should be active"
    end
  end

  test "inactive scope should return only inactive watches" do
    inactive_watches = Watch.inactive

    inactive_watches.each do |watch|
      assert_not watch.active?, "Watch #{watch.id} should be inactive"
    end
  end

  test "should calculate next_scrape_at correctly" do
    # @watch is a search type with 4 hour frequency
    freeze_time = Time.current.beginning_of_minute # Remove seconds/microseconds

    travel_to freeze_time do
      @watch.record_scrape_attempt(3)
      expected_time = freeze_time + 4.hours
      actual_time = @watch.next_scrape_at

      # Allow small time difference due to processing time
      assert_in_delta expected_time.to_f, actual_time.to_f, 5.0, "Time should be within 5 seconds"
    end
  end

  test "url_domain should handle invalid URIs" do
    @watch.url = "http://[invalid]"
    assert_equal "Invalid URL", @watch.url_domain
  end

  test "omit_terms_array= should set omit_terms from array" do
    @watch.omit_terms_array = [ "term1", "term2", "term3" ]
    assert_equal "term1, term2, term3", @watch.omit_terms
  end

  test "omit_terms_array= should handle empty and whitespace terms" do
    @watch.omit_terms_array = [ "term1", "", " term2 ", "term3" ]
    assert_equal "term1, term2, term3", @watch.omit_terms
  end

  test "time_until_next_scrape should return 0 for past times" do
    @watch.next_scrape_at = 2.hours.ago
    assert_equal 0, @watch.time_until_next_scrape
  end

  test "scrape_frequency_hours should return correct values for different types" do
    @watch.watch_type = "search"
    assert_equal 4, @watch.scrape_frequency_hours

    @watch.watch_type = "product"
    assert_equal 24, @watch.scrape_frequency_hours

    @watch.watch_type = "category"
    assert_equal 6, @watch.scrape_frequency_hours

    @watch.watch_type = "unknown"
    assert_equal 12, @watch.scrape_frequency_hours
  end

  test "scrape_success_rate should calculate correctly" do
    # Test with no scrapes
    @watch.scrape_count = 0
    assert_equal 0, @watch.scrape_success_rate

    # Test with successful scrapes (products_found > 0)
    @watch.scrape_count = 5
    @watch.products_found = 1
    # Logic: min(1, 1) * 5 = 5, so 5/5 * 100 = 100%
    assert_equal 100.0, @watch.scrape_success_rate

    # Test with no products found
    @watch.products_found = 0
    # Logic: min(0, 1) * 5 = 0, so 0/5 * 100 = 0%
    assert_equal 0.0, @watch.scrape_success_rate
  end

  test "status_color should return correct colors" do
    @watch.active = false
    assert_equal "gray", @watch.status_color

    @watch.active = true
    @watch.next_scrape_at = 1.hour.ago
    assert_equal "green", @watch.status_color # ready

    @watch.next_scrape_at = 1.hour.from_now
    @watch.last_scraped_at = 30.minutes.ago
    assert_equal "blue", @watch.status_color # recently_scraped

    @watch.last_scraped_at = nil
    assert_equal "yellow", @watch.status_color # scheduled
  end

  test "should handle watch activation and deactivation" do
    # Test activation
    @watch.active = false
    @watch.next_scrape_at = nil
    @watch.save!

    @watch.active = true
    @watch.save!
    assert_not_nil @watch.next_scrape_at

    # Test deactivation
    @watch.active = false
    @watch.save!
    assert_nil @watch.next_scrape_at
  end

  test "should set next_scrape_at on creation for active watches" do
    watch = Watch.new(
      name: "Test Active Watch",
      url: "https://example.com/active",
      watch_type: "search",
      active: true
    )

    assert_nil watch.next_scrape_at
    watch.save!
    assert_not_nil watch.next_scrape_at
  end

  test "should not set next_scrape_at on creation for inactive watches" do
    watch = Watch.create!(
      name: "Test Inactive Watch",
      url: "https://example.com/inactive",
      watch_type: "search",
      active: false
    )

    assert_nil watch.next_scrape_at
  end
end
