require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    user = User.create!(email_address: "test@example.com", password: "password123")

    post session_url, params: { email_address: "test@example.com", password: "password123" }
    assert_redirected_to root_url
  end

  test "should not create session with invalid credentials" do
    User.create!(email_address: "test@example.com", password: "password123")

    post session_url, params: { email_address: "test@example.com", password: "wrongpassword" }
    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "should destroy session" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    post session_url, params: { email_address: "test@example.com", password: "password123" }

    delete session_url
    assert_redirected_to new_session_path
  end
end
