ENV["RAILS_ENV"] ||= "test"

# SimpleCov configuration
require "simplecov"
SimpleCov.start "rails" do
  minimum_coverage 66  # Current coverage level
  minimum_coverage_by_file 0   # Allow files with 0% for now, focus on overall coverage

  add_filter "/app/channels/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/test/"
  add_filter "/vendor/"

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Services", "app/services"
  add_group "Helpers", "app/helpers"
  add_group "Views", "app/views"

  # Enable JSON formatter for CI
  if ENV["CI"]
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::SimpleFormatter
    ])
  end
end

require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Disable parallelization in CI for accurate coverage reporting
    unless ENV["CI"]
      parallelize(workers: :number_of_processors)
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    def sign_in(user)
      session = user.sessions.create!(user_agent: "Test", ip_address: "127.0.0.1")
      post session_url, params: {
        email_address: user.email_address,
        password: "password123"
      }
    end

    def sign_out
      delete session_url
    end
  end
end
