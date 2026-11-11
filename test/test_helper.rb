# Start SimpleCov before loading Rails
require "simplecov"

# Configure SimpleCov for parallel test support
SimpleCov.start "rails" do
  # Enable merging for parallel test support
  merging true

  # Set minimum coverage percentage (adjusted for phased development)
  minimum_coverage 99.0
  coverage(:line) { minimum 90, per: :file }

  # Enable branch coverage tracking
  enable_coverage :branch

  # Add filters for files/directories to exclude from coverage
  skip "/spec/"
  skip "/config/"
  skip "/vendor/"
  skip "/db/"
  skip "/bin/"
  skip "/test/"
  skip "app/channels/application_cable/connection.rb"
  skip "app/jobs/application_job.rb"
  skip "app/mailers/application_mailer.rb"
  skip "app/models/application_record.rb"
  skip "app/models/current.rb"
  skip "app/helpers/application_helper.rb"
  skip "app/mailers/passwords_mailer.rb"

  # Group coverage results for better organization
  group "Controllers", "app/controllers"
  group "Models", "app/models"
  group "Services", "app/services"
  group "Jobs", "app/jobs"
  group "Helpers", "app/helpers"
  group "Mailers", "app/mailers"
  group "Channels", "app/channels"
  group "Libraries", "lib/"

  # Track files
  cover "{app,lib}/**/*.rb"

  # Set up formatters
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter
  ])

  # Maximum coverage drop allowed (temporarily increased during development)
  maximum_coverage_drop 100
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Parallel testing disabled due to SimpleCov merging issues
    # Tests run quickly enough in series (~0.6s for 75 tests)
    # TODO: Investigate SimpleCov-parallel gem for proper merging
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Helper method to sign in a user for testing
    def sign_in(user)
      session = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
      post session_path, params: { email_address: user.email_address, password: "password" }
    end
  end
end
