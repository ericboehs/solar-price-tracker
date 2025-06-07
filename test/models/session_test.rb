require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "should belong to user" do
    session = sessions(:test_session)
    assert_respond_to session, :user
    assert_kind_of User, session.user
  end

  test "should require user" do
    session = Session.new(user_agent: "Test", ip_address: "127.0.0.1")
    assert_not session.valid?
    assert session.errors[:user].present?
  end

  test "should create with valid attributes" do
    user = users(:user_one)
    session = user.sessions.build(user_agent: "Mozilla/5.0", ip_address: "192.168.1.1")
    assert session.valid?
    assert session.save
  end

  test "should store user agent" do
    session = sessions(:test_session)
    assert_equal "Mozilla/5.0 Test Browser", session.user_agent
  end

  test "should store ip address" do
    session = sessions(:test_session)
    assert_equal "127.0.0.1", session.ip_address
  end
end
