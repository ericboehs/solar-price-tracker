require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  test "has session attribute" do
    assert_respond_to Current, :session
    assert_respond_to Current, :session=
  end

  test "delegates user to session" do
    user = users(:user_one)
    session = sessions(:test_session)

    Current.session = session
    assert_equal user, Current.user
  end

  test "handles nil session gracefully" do
    Current.session = nil
    assert_nil Current.user
  end

  test "resets attributes between requests" do
    session = sessions(:test_session)
    Current.session = session
    assert_equal session, Current.session

    Current.reset
    assert_nil Current.session
  end
end
