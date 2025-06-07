require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "require_authentication redirects when no session" do
    get watches_url
    assert_redirected_to new_session_path
  end

  test "terminate_session clears session" do
    user = users(:user_one)
    sign_in(user)

    delete session_url
    assert_redirected_to new_session_path
  end

  test "after_authentication_url returns stored url" do
    # Visit a protected page which stores return_to
    get watches_url
    assert_redirected_to new_session_path

    # Sign in and check redirect
    user = users(:user_one)
    post session_url, params: { email_address: user.email_address, password: "password123" }
    assert_redirected_to watches_url
  end
end
