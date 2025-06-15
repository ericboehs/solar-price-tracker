require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get welcome_index_path
    assert_response :success
  end

  test "should allow unauthenticated access" do
    get welcome_index_path
    assert_response :success
    assert_select "h1", "Solar Price Tracker"
  end

  test "should redirect unauthenticated users from root to welcome" do
    get root_url
    assert_redirected_to controller: :welcome, action: :index
  end
end
