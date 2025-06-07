require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "includes authentication concern" do
    assert ApplicationController.ancestors.include?(Authentication)
  end

  test "blocks non-modern browsers" do
    # Test with an old browser user agent
    old_browser_agent = "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko"

    get root_url, headers: { "User-Agent" => old_browser_agent }
    assert_response :not_acceptable
  end

  test "allows modern browsers" do
    # Test with a modern browser user agent
    modern_browser_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    get root_url, headers: { "User-Agent" => modern_browser_agent }
    assert_response :success
  end
end
