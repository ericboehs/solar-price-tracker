require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "test@example.com", password: "password123")
    @admin = User.create!(email_address: "admin@example.com", password: "password123", admin: true)
  end

  test "should redirect non-admin users" do
    sign_in_as(@user)
    get admin_path
    assert_redirected_to root_path
    assert_equal "Access denied. Admin privileges required.", flash[:alert]
  end

  test "should allow admin users" do
    sign_in_as(@admin)
    get admin_path
    assert_response :success
  end

  test "should redirect unauthenticated users to sign in" do
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
