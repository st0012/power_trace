require "bundler/setup"
require "power_trace"
require "fixtures"
require "pry"
require "helpers/io_capture_helper"

RSpec.configure do |config|
  config.include IOCaptureHelper
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
