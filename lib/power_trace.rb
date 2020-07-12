require "power_trace/version"
require "power_trace/stack"

module PowerTrace
  cattr_accessor :colorize_backtrace, instance_accessor: false
  self.colorize_backtrace = true

  cattr_accessor :replace_backtrace, instance_accessor: false
  self.replace_backtrace = false

  cattr_accessor :adjust_rspec_error, instance_accessor: false
  self.adjust_rspec_error = false

  def power_trace(options = {})
    PowerTrace::Stack.new(options)
  end
end

include PowerTrace

require "power_trace/exception_patch"

require "rspec" rescue LoadError

if defined?(RSpec)
  require "power_trace/rspec_patch"
end
