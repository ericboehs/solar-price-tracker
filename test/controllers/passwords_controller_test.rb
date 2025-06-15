require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email_address: "test@example.com", password: "password123")
  end

  test "should get new" do
    get new_password_url
    assert_response :success
  end

  test "should create password reset for existing user" do
    assert_enqueued_jobs 1 do
      post passwords_url, params: { email_address: @user.email_address }
    end
    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "should handle password reset for non-existing user" do
    assert_enqueued_jobs 0 do
      post passwords_url, params: { email_address: "nonexistent@example.com" }
    end
    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "should get edit with valid token" do
    token = @user.generate_token_for(:password_reset)
    get edit_password_url(token)
    assert_response :success
  end

  test "should redirect edit with invalid token" do
    get edit_password_url("invalid_token")
    assert_redirected_to new_password_path
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "should update password with valid token and matching passwords" do
    token = @user.generate_token_for(:password_reset)
    put password_url(token), params: {
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }
    assert_redirected_to new_session_path
    assert_equal "Password has been reset.", flash[:notice]
  end

  test "should not update password with mismatched confirmation" do
    token = @user.generate_token_for(:password_reset)
    put password_url(token), params: {
      password: "newpassword123",
      password_confirmation: "differentpassword"
    }
    assert_redirected_to edit_password_path(token)
    assert_equal "Passwords did not match.", flash[:alert]
  end
end
