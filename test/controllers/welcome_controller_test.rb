require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should allow unauthenticated access" do
    get root_url
    assert_response :success
    assert_select "h1", "Solar Price Tracker"
  end
end
