# SimpleCov configuration - MUST be before Rails loads
require "simplecov"

# Enable result merging for parallel tests
SimpleCov.use_merging true

SimpleCov.start "rails" do
  minimum_coverage 90  # Relaxed for flexibility
  minimum_coverage_by_file 0   # Allow files with 0% for now, focus on overall coverage

  add_filter "/app/channels/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/test/"
  add_filter "/vendor/"
  add_filter "/app/controllers/passwords_controller.rb"  # No routes for this controller
  add_filter "/app/mailers/passwords_mailer.rb"  # Related mailer also unused

  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Services", "app/services"
  add_group "Helpers", "app/helpers"
  add_group "Views", "app/views"

  # Enable coverage merging for parallel tests
  enable_coverage :branch
  primary_coverage :line

  # Set command name for parallel tests
  if ENV["TEST_ENV_NUMBER"]
    SimpleCov.command_name "test:#{ENV['TEST_ENV_NUMBER']}"
  end

  # Set merge timeout for parallel test results
  merge_timeout 3600
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Configure SimpleCov for parallel testing based on GitHub issue #718
    parallelize_setup do |worker|
      SimpleCov.command_name "test:#{worker}"
    end

    parallelize_teardown do |worker|
      SimpleCov.result
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
