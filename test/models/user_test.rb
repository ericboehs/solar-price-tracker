require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should have secure password" do
    user = User.new(email_address: "test@example.com", password: "password123")
    assert user.respond_to?(:authenticate)
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong")
  end

  test "should require password" do
    user = User.new(email_address: "test@example.com")
    assert_not user.valid?
    assert user.errors[:password].present?
  end

  test "should normalize email address" do
    user = User.new(email_address: "  TEST@EXAMPLE.COM  ", password: "password123")
    user.valid?
    assert_equal "test@example.com", user.email_address
  end

  test "should have many sessions" do
    user = users(:user_one)
    assert_respond_to user, :sessions
    assert_kind_of ActiveRecord::Associations::CollectionProxy, user.sessions
  end

  test "should destroy dependent sessions" do
    user = users(:user_two)  # Use user_two to avoid interference from fixtures
    session = user.sessions.create!(user_agent: "Test", ip_address: "127.0.0.1")

    initial_count = user.sessions.count
    assert_difference "Session.count", -initial_count do
      user.destroy
    end
  end

  test "should authenticate by email and password" do
    user = users(:user_one)
    authenticated_user = User.authenticate_by(email_address: user.email_address, password: "password123")
    assert_equal user, authenticated_user
  end

  test "should not authenticate with wrong password" do
    user = users(:user_one)
    authenticated_user = User.authenticate_by(email_address: user.email_address, password: "wrong")
    assert_nil authenticated_user
  end

  test "should not authenticate with non-existent email" do
    authenticated_user = User.authenticate_by(email_address: "nonexistent@example.com", password: "password123")
    assert_nil authenticated_user
  end
end
