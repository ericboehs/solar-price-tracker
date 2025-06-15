require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_registration_url
    assert_response :success
  end

  test "should create user with valid attributes" do
    assert_difference("User.count", 1) do
      post registrations_url, params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to root_url
    assert_equal "Welcome! You have signed up successfully.", flash[:notice]
  end

  test "should not create user with invalid attributes" do
    assert_no_difference("User.count") do
      post registrations_url, params: {
        user: {
          email_address: "",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create user with existing email" do
    User.create!(email_address: "existing@example.com", password: "password123")

    assert_no_difference("User.count") do
      post registrations_url, params: {
        user: {
          email_address: "existing@example.com",
          password: "newpassword123",
          password_confirmation: "newpassword123"
        }
      }
    end
    assert_response :unprocessable_entity
  end
end
