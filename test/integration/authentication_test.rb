require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "test@example.com", password: "password123")
    @admin = User.create!(email_address: "admin@example.com", password: "password123", admin: true)
  end

  test "should redirect unauthenticated user from root to welcome" do
    get root_path
    assert_redirected_to controller: :welcome, action: :index
  end

  test "should redirect authenticated user from root to products" do
    sign_in_as(@user)
    get root_path
    assert_redirected_to products_path
  end

  test "should show admin badge for admin users on welcome page" do
    sign_in_as(@admin)
    get welcome_index_path
    assert_response :success
    assert_select "span", text: "Admin"
  end

  test "should not show admin badge for regular users on welcome page" do
    sign_in_as(@user)
    get welcome_index_path
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
