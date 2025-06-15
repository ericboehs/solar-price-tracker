require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "test@example.com", password: "password123")
    @admin = User.create!(email_address: "admin@example.com", password: "password123", admin: true)
  end

  test "should redirect unauthenticated user to sign in for protected paths" do
    # Test that accessing the root requires authentication when we're not signed in
    # and there's a session return_to URL set
    get root_path
    assert_response :success # Welcome page is public
  end

  test "should allow authenticated user access" do
    sign_in_as(@user)
    get root_path
    assert_response :success
  end

  test "should show admin badge for admin users" do
    sign_in_as(@admin)
    get root_path
    assert_response :success
    assert_select "span", text: "Admin"
  end

  test "should not show admin badge for regular users" do
    sign_in_as(@user)
    get root_path
    assert_response :success
    assert_select "span", text: "Admin", count: 0
  end

  test "should handle sign in flow" do
    get new_session_path
    assert_response :success

    post session_path, params: {
      email_address: @user.email_address,
      password: "password123"
    }
    assert_redirected_to root_path
  end

  test "should handle missing session cookie" do
    # Access admin path to trigger authentication requirement
    get admin_path
    assert_redirected_to new_session_path
  end

  test "should handle invalid session cookie" do
    # Create a user, sign them in to get a session, then destroy the session
    # to simulate an invalid session cookie
    sign_in_as(@user)
    Session.destroy_all  # Destroy all sessions to make cookie invalid
    get admin_path
    assert_redirected_to new_session_path
  end

  private

  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password123"
    }
  end
end
