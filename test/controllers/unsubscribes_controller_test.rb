require "test_helper"

class UnsubscribesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(price_alerts: true)
    @token = @user.generate_token_for(:unsubscribe)
  end

  test "show asks for confirmation without changing anything" do
    get unsubscribe_path(token: @token)
    assert_response :success
    assert_select "form[action=?]", unsubscribe_path(token: @token)
    assert @user.reload.price_alerts?
  end

  test "create unsubscribes and the link stops working" do
    post unsubscribe_path(token: @token)
    assert_redirected_to welcome_index_path
    assert_not @user.reload.price_alerts?

    get unsubscribe_path(token: @token)
    assert_redirected_to welcome_index_path
    assert_equal "That unsubscribe link is invalid or already used.", flash[:alert]
  end

  test "bad token is rejected" do
    post unsubscribe_path(token: "nope")
    assert_redirected_to welcome_index_path
    assert @user.reload.price_alerts?
  end
end
