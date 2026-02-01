require "test_helper"

# Load system tests if any exist.
Dir[File.join(__dir__, "system", "**", "*_test.rb")].sort.each do |path|
  require path
end
