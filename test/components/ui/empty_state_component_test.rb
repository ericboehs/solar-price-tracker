require "test_helper"

class Ui::EmptyStateComponentTest < ViewComponent::TestCase
  test "renders basic empty state with title and description" do
    render_inline(Ui::EmptyStateComponent.new(
      title: "No items found",
      description: "There are no items to display at this time."
    ))

    assert_selector "h3", text: "No items found"
    assert_selector "p", text: "There are no items to display at this time."
    assert_selector "svg" # Default icon should be present
  end

  test "renders with products icon" do
    render_inline(Ui::EmptyStateComponent.new(
      title: "No products",
      description: "No products available.",
      icon: :products
    ))

    assert_selector "svg"
    assert_selector "h3", text: "No products"
  end

  test "renders with watches icon" do
    render_inline(Ui::EmptyStateComponent.new(
      title: "No watches",
      description: "No watches configured.",
      icon: :watches
    ))

    assert_selector "svg"
    assert_selector "h3", text: "No watches"
  end

  test "renders with action buttons" do
    actions = [
      { text: "Create Item", path: "/items/new" },
      { text: "Import Items", path: "/items/import" }
    ]

    render_inline(Ui::EmptyStateComponent.new(
      title: "No items",
      description: "Get started by creating an item.",
      actions: actions
    ))

    assert_selector "a[href='/items/new']", text: "Create Item"
    assert_selector "a[href='/items/import']", text: "Import Items"
  end

  test "renders without actions when none provided" do
    render_inline(Ui::EmptyStateComponent.new(
      title: "No items",
      description: "No items available."
    ))

    assert_no_selector "a"
  end

  test "uses proper styling classes" do
    render_inline(Ui::EmptyStateComponent.new(
      title: "Test",
      description: "Test description"
    ))

    assert_selector "div.text-center.py-12"
    assert_selector "h3.text-sm.font-semibold"
    assert_selector "p.text-sm"
  end

  test "renders with search icon" do
    render_inline(Ui::EmptyStateComponent.new(
      title: "No results",
      description: "Try adjusting your search.",
      icon: :search
    ))

    assert_selector "svg"
    assert_selector "h3", text: "No results"
  end

  test "renders with inbox icon" do
    render_inline(Ui::EmptyStateComponent.new(
      title: "Empty inbox",
      description: "No messages to display.",
      icon: :inbox
    ))

    assert_selector "svg"
    assert_selector "h3", text: "Empty inbox"
  end
end
