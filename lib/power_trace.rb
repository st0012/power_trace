require "power_trace/version"
require "power_trace/stack"

module PowerTrace
  cattr_accessor :colorize_backtrace, instance_accessor: false
  self.colorize_backtrace = true

  cattr_accessor :replace_backtrace, instance_accessor: false
  self.replace_backtrace = false

  cattr_accessor :power_rails_trace, instance_accessor: false
  self.power_rails_trace = false

  cattr_accessor :power_rspec_trace, instance_accessor: false
  self.power_rspec_trace = false

  cattr_accessor :power_minitest_trace, instance_accessor: false
  self.power_rspec_trace = false

  cattr_accessor :trace_limit, instance_accessor: false
  self.trace_limit = 50

  def power_trace(options = {})
    PowerTrace::Stack.new(options)
  end

  class << self
    def power_rails_trace=(val)
      if val
        require "power_trace/rails_patch"
      end

      @@power_rails_trace = val
    end

    def print_power_trace_error(exception)
      puts(exception)
      puts(exception.backtrace)
      puts("there's a bug in power_trace, please open an issue at https://github.com/st0012/power_trace")
    end
  end
end

include PowerTrace

require "power_trace/exception_patch"

begin
  require "rspec"
  require "power_trace/rspec_patch"
rescue LoadError
end

begin
  require "minitest"
  require "power_trace/minitest_patch"
rescue LoadError
end
