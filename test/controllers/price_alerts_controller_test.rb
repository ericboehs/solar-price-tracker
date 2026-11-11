require "test_helper"

class PriceAlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    post session_path, params: { email_address: @user.email_address, password: "password" }
  end

  test "turns alerts on and off" do
    post price_alerts_path
    assert_redirected_to products_path
    assert @user.reload.price_alerts?

    get products_path
    assert_select "form[action=?] input[name=_method][value=delete]", price_alerts_path

    delete price_alerts_path
    assert_redirected_to products_path
    assert_not @user.reload.price_alerts?
  end

  test "requires sign in" do
    delete session_path
    post price_alerts_path
    assert_redirected_to new_session_path
  end
end
