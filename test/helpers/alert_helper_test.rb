require "test_helper"

class AlertHelperTest < ActionView::TestCase
  include AlertHelper

  def test_alert_helper_method
    result = alert(:success, "Test message")
    assert_match /role="alert"/, result
    assert_match /Test message/, result
  end

  def test_success_alert_helper
    result = success_alert("Success message")
    assert_match /bg-green-50/, result
    assert_match /Success message/, result
  end

  def test_error_alert_helper
    result = error_alert("Error message")
    assert_match /bg-red-50/, result
    assert_match /Error message/, result
  end

  def test_warning_alert_helper
    result = warning_alert("Warning message")
    assert_match /bg-yellow-50/, result
    assert_match /Warning message/, result
  end

  def test_info_alert_helper
    result = info_alert("Info message")
    assert_match /bg-blue-50/, result
    assert_match /Info message/, result
  end

  def test_alert_helper_with_options
    result = alert(:info, "Message", classes: "custom-class", dismissible: false)
    assert_match /custom-class/, result
    refute_match /data-action.*dismiss/, result
  end
end