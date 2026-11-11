require "application_system_test_case"

class Admin::WatchesSystemTest < ApplicationSystemTestCase
  setup do
    @watch = watches(:one)
    visit new_session_path
    fill_in "email_address", with: users(:admin).email_address
    fill_in "password", with: "password"
    find("input[type=submit],button[type=submit]", match: :first).click
    assert_current_path products_path
  end

  test "Scrape button on the index queues a scrape" do
    visit admin_watches_path
    within("tr", text: @watch.name) { click_on "Scrape" }

    assert_text "Scraping job queued for this watch."
    assert_current_path admin_watch_path(@watch)
  end

  test "Delete button on the index deletes after confirming" do
    visit admin_watches_path
    accept_confirm("Delete this watch?") do
      within("tr", text: @watch.name) { click_on "Delete" }
    end

    assert_text "Watch was successfully deleted."
    assert_no_text @watch.name
  end
end
