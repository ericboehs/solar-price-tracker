require "test_helper"

class Admin::WatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:admin)
    @watch = watches(:one)
  end

  test "should get index" do
    sign_in @user
    get admin_watches_url
    assert_response :success
  end

  test "should get show" do
    sign_in @user
    get admin_watch_url(@watch)
    assert_response :success
  end

  test "should get new" do
    sign_in @user
    get new_admin_watch_url
    assert_response :success
  end

  test "should create watch" do
    sign_in @user
    assert_difference("Watch.count") do
      post admin_watches_url, params: {
        watch: {
          name: "Test Watch",
          url: "https://example.com/search",
          watch_type: "search",
          active: true,
          exclude_bundles: true
        }
      }
    end
    assert_redirected_to admin_watch_url(Watch.last)
  end

  test "should get edit" do
    sign_in @user
    get edit_admin_watch_url(@watch)
    assert_response :success
  end

  test "should update watch" do
    sign_in @user
    patch admin_watch_url(@watch), params: {
      watch: {
        name: "Updated Watch"
      }
    }
    assert_redirected_to admin_watch_url(@watch)
  end

  test "should destroy watch" do
    sign_in @user
    assert_difference("Watch.count", -1) do
      delete admin_watch_url(@watch)
    end
    assert_redirected_to admin_watches_url
  end

  test "should require admin access" do
    get admin_watches_url
    assert_redirected_to new_session_path
  end

  test "should handle invalid watch creation" do
    sign_in @user
    assert_no_difference("Watch.count") do
      post admin_watches_url, params: {
        watch: {
          name: "", # Invalid - name required
          url: "invalid-url", # Invalid URL format
          watch_type: "invalid" # Invalid watch type
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should handle invalid watch update" do
    sign_in @user
    patch admin_watch_url(@watch), params: {
      watch: {
        name: "", # Invalid - name required
        url: "invalid-url" # Invalid URL format
      }
    }
    assert_response :unprocessable_entity
  end


  test "should trigger scrape job when scrape action called" do
    sign_in @user
    assert_enqueued_with(job: ProcessWatchJob, args: [ @watch ]) do
      post admin_scrape_watch_url(@watch)
    end
    assert_redirected_to admin_watch_url(@watch)
    assert_equal "Scraping job queued for this watch.", flash[:notice]
  end

  test "should show watch statistics in index" do
    sign_in @user
    get admin_watches_url
    assert_response :success

    # Check that page shows statistics (without using assigns)
    assert_select ".grid", minimum: 1 # Statistics cards should be present
    assert_select "dt", text: "Total Watches" # Check for statistics labels
    assert_select "dt", text: "Active"
    assert_select "dt", text: "Inactive"
  end

  test "should display watch details correctly" do
    sign_in @user
    get admin_watch_url(@watch)
    assert_response :success

    # Check that important elements are present in the response
    assert_select "h1", text: @watch.display_name
    assert_select ".text-orange-600", minimum: 1 # URL link should be present
  end

  test "should handle watch creation with all optional fields" do
    sign_in @user
    assert_difference("Watch.count") do
      post admin_watches_url, params: {
        watch: {
          name: "Full Test Watch",
          url: "https://example.com/full-test",
          watch_type: "product",
          description: "A comprehensive test watch",
          active: false,
          exclude_bundles: false,
          omit_terms: "refurbished,damaged,used"
        }
      }
    end

    watch = Watch.last
    assert_equal "Full Test Watch", watch.name
    assert_equal "https://example.com/full-test", watch.url
    assert_equal "product", watch.watch_type
    assert_equal "A comprehensive test watch", watch.description
    assert_not watch.active?
    assert_not watch.exclude_bundles?
    assert_equal "refurbished,damaged,used", watch.omit_terms
  end
end
