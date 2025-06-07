require "test_helper"

class WatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get watches_url
    assert_response :success
  end

  test "should get show" do
    watch = watches(:one)
    get watch_url(watch)
    assert_response :success
  end

  test "should get new" do
    get new_watch_url
    assert_response :success
  end

  test "should create watch" do
    assert_difference("Watch.count") do
      post watches_url, params: { watch: { name: "Test Watch", url: "https://example.com", active: true } }
    end
    assert_redirected_to watch_url(Watch.last)
  end

  test "should get edit" do
    watch = watches(:one)
    get edit_watch_url(watch)
    assert_response :success
  end

  test "should update watch" do
    watch = watches(:one)
    patch watch_url(watch), params: { watch: { name: "Updated Watch" } }
    assert_redirected_to watch_url(watch)
  end

  test "should destroy watch" do
    watch = watches(:one)
    assert_difference("Watch.count", -1) do
      delete watch_url(watch)
    end
    assert_redirected_to watches_url
  end
end
