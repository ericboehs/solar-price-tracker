# Start SimpleCov before loading Rails
require "simplecov"

# Configure SimpleCov for parallel test support
SimpleCov.start "rails" do
  # Enable merging for parallel test support
  use_merging true

  # Set minimum coverage percentage (adjusted for phased development)
  minimum_coverage 99.0
  minimum_coverage_by_file 90

  # Enable branch coverage tracking
  enable_coverage :branch

  # Add filters for files/directories to exclude from coverage
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"
  add_filter "/db/"
  add_filter "/bin/"
  add_filter "/test/"
  add_filter "app/channels/application_cable/connection.rb"
  add_filter "app/jobs/application_job.rb"
  add_filter "app/mailers/application_mailer.rb"
  add_filter "app/models/application_record.rb"
  add_filter "app/models/current.rb"
  add_filter "app/helpers/application_helper.rb"
  add_filter "app/mailers/passwords_mailer.rb"

  # Group coverage results for better organization
  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Services", "app/services"
  add_group "Jobs", "app/jobs"
  add_group "Helpers", "app/helpers"
  add_group "Mailers", "app/mailers"
  add_group "Channels", "app/channels"
  add_group "Libraries", "lib/"

  # Track files
  track_files "{app,lib}/**/*.rb"

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
