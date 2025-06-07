ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

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
