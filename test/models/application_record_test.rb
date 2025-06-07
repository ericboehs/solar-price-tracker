require "test_helper"

class ApplicationRecordTest < ActiveSupport::TestCase
  test "is abstract class" do
    assert ApplicationRecord.abstract_class?
  end

  test "inherits from ActiveRecord::Base" do
    assert ApplicationRecord < ActiveRecord::Base
  end
end
