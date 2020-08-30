require "bundler/setup"
require "power_trace"
require "fixtures"
require "pry"
require "helpers/io_capture_helper"

require 'simplecov'
SimpleCov.start

if ENV["CI"]
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

RSpec.configure do |config|
  config.include IOCaptureHelper
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  module ConfigHelper
    def with_integration(integration)
      begin
        original_integrations = PowerTrace.integrations
        PowerTrace.integrations = integration
        PowerTrace.colorize_backtrace = false

        yield
      ensure
        PowerTrace.integrations = original_integrations
        PowerTrace.colorize_backtrace = true
      end
    end
  end

  config.include ConfigHelper
end
