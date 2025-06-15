require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should create user with valid attributes" do
    user = User.new(email_address: "test@example.com", password: "password123")
    assert user.save
    assert user.email_address == "test@example.com"
  end

  test "should authenticate user with correct credentials" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    authenticated_user = User.authenticate_by(email_address: "test@example.com", password: "password123")
    assert_equal user, authenticated_user
  end

  test "should not authenticate user with incorrect credentials" do
    User.create!(email_address: "test@example.com", password: "password123")
    authenticated_user = User.authenticate_by(email_address: "test@example.com", password: "wrongpassword")
    assert_nil authenticated_user
  end

  test "should default to non-admin user" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    assert_not user.admin?
  end

  test "should be able to make user admin" do
    user = User.create!(email_address: "test@example.com", password: "password123")
    user.make_admin!
    assert user.admin?
  end

  test "should be able to remove admin privileges" do
    user = User.create!(email_address: "test@example.com", password: "password123", admin: true)
    assert user.admin?
    user.remove_admin!
    assert_not user.admin?
  end
end
