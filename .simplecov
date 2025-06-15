# SimpleCov configuration
SimpleCov.start 'rails' do
  # Set minimum coverage percentage
  minimum_coverage 95

  # Set coverage percentage precision
  minimum_coverage_by_file 80

  # Add filters for files/directories to exclude from coverage
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/db/'
  add_filter '/bin/'
  add_filter '/test/'

  # Group coverage results for better organization
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'
  add_group 'Jobs', 'app/jobs'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Channels', 'app/channels'
  add_group 'Libraries', 'lib/'

  # Use Rails' default profile with some modifications
  track_files '{app,lib}/**/*.rb'

  # Enable coverage for branches (Ruby 2.5+)
  enable_coverage :branch

  # Set up formatters
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter
  ])

  # Refuse to run tests if coverage drops below threshold
  refuse_coverage_drop :line, :branch

  # Maximum coverage drop allowed
  maximum_coverage_drop 5
end
