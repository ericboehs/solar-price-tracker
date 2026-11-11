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

  test "sign-ups closed: new and create redirect to sign in" do
    with_registrations_open(false) do
      get new_registration_url
      assert_redirected_to new_session_path
      assert_equal "Sign-ups are closed.", flash[:alert]

      assert_no_difference("User.count") do
        post registrations_url, params: { user: { email_address: "x@example.com", password: "password123", password_confirmation: "password123" } }
      end
      assert_redirected_to new_session_path
    end
  end

  test "sign-ups closed: sign-up links are hidden" do
    with_registrations_open(false) do
      get new_session_url
      assert_select "a[href=?]", new_registration_path, count: 0
      get welcome_index_url
      assert_select "a[href=?]", new_registration_path, count: 0
    end
  end

  test "sign-ups open: sign-up links are shown" do
    get welcome_index_url
    assert_select "a[href=?]", new_registration_path
  end

  private
    def with_registrations_open(value)
      original = Rails.configuration.x.registrations_open
      Rails.configuration.x.registrations_open = value
      yield
    ensure
      Rails.configuration.x.registrations_open = original
    end
end
