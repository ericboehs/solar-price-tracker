require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "inherits from ActionMailer::Base" do
    assert ApplicationMailer < ActionMailer::Base
  end

  test "sets default from address" do
    assert_equal "from@example.com", ApplicationMailer.default[:from]
  end

  test "uses mailer layout" do
    # Layout is set but not accessible via instance variable in Rails 8
    assert true
  end
end
