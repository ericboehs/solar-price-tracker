require "test_helper"

class Ui::AlertComponentTest < ViewComponent::TestCase
  def test_renders_success_alert
    render_inline(Ui::AlertComponent.new(type: :success, message: "Operation successful"))

    assert_selector "[role='alert']"
    assert_text "Operation successful"
    assert_selector ".bg-green-50"
    assert_selector "svg.text-green-400"
  end

  def test_renders_error_alert
    render_inline(Ui::AlertComponent.new(type: :error, message: "Something went wrong"))

    assert_selector "[role='alert']"
    assert_text "Something went wrong"
    assert_selector ".bg-red-50"
    assert_selector "svg.text-red-400"
  end

  def test_renders_warning_alert
    render_inline(Ui::AlertComponent.new(type: :warning, message: "Warning message"))

    assert_selector "[role='alert']"
    assert_text "Warning message"
    assert_selector ".bg-yellow-50"
    assert_selector "svg.text-yellow-400"
  end

  def test_renders_info_alert
    render_inline(Ui::AlertComponent.new(type: :info, message: "Information"))

    assert_selector "[role='alert']"
    assert_text "Information"
    assert_selector ".bg-blue-50"
    assert_selector "svg.text-blue-400"
  end

  def test_renders_dismissible_by_default
    render_inline(Ui::AlertComponent.new(type: :info, message: "Info"))

    assert_selector "button[data-action='click->alert#dismiss']"
    assert_text "Dismiss"
  end

  def test_renders_non_dismissible_when_specified
    render_inline(Ui::AlertComponent.new(type: :info, message: "Info", dismissible: false))

    refute_selector "button[data-action='click->alert#dismiss']"
  end

  def test_handles_unknown_type_gracefully
    render_inline(Ui::AlertComponent.new(type: :unknown, message: "Unknown type"))

    assert_selector "[role='alert']"
    assert_text "Unknown type"
    assert_selector ".bg-blue-50"  # Should default to info styling
  end

  def test_accepts_custom_classes
    render_inline(Ui::AlertComponent.new(type: :info, message: "Custom", classes: "mt-4 mx-4"))

    assert_selector ".mt-4.mx-4"
  end

  def test_includes_stimulus_controller
    render_inline(Ui::AlertComponent.new(type: :info, message: "Test"))

    assert_selector "[data-controller='alert']"
  end
end
