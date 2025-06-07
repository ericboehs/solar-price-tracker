require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
  end

  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    post session_url, params: { email_address: @user.email_address, password: "password123" }
    assert_redirected_to root_url
    assert_not_nil cookies[:session_id]
  end

  test "should not create session with invalid credentials" do
    post session_url, params: { email_address: @user.email_address, password: "wrong" }
    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
    assert_nil cookies[:session_id]
  end

  test "should not create session with non-existent user" do
    post session_url, params: { email_address: "nonexistent@example.com", password: "password123" }
    assert_redirected_to new_session_path
    assert_equal "Try another email address or password.", flash[:alert]
    assert_nil cookies[:session_id]
  end

  test "should destroy session" do
    sign_in(@user)
    # Create a session first
    post session_url, params: { email_address: @user.email_address, password: "password123" }
    assert_not_nil cookies[:session_id]

    delete session_url
    assert_redirected_to new_session_path
    # Cookie is deleted but may return empty string instead of nil
    assert cookies[:session_id].blank?
  end


  test "should allow unauthenticated access to new and create" do
    get new_session_url
    assert_response :success

    post session_url, params: { email_address: "test@example.com", password: "test" }
    assert_response :redirect
  end
end
