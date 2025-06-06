require "test_helper"

class WatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get watches_index_url
    assert_response :success
  end

  test "should get show" do
    get watches_show_url
    assert_response :success
  end

  test "should get new" do
    get watches_new_url
    assert_response :success
  end

  test "should get create" do
    get watches_create_url
    assert_response :success
  end

  test "should get edit" do
    get watches_edit_url
    assert_response :success
  end

  test "should get update" do
    get watches_update_url
    assert_response :success
  end

  test "should get destroy" do
    get watches_destroy_url
    assert_response :success
  end
end
