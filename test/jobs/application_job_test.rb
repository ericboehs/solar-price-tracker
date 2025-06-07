require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  test "inherits from ActiveJob::Base" do
    assert ApplicationJob < ActiveJob::Base
  end
end
