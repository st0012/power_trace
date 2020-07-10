require "power_trace/version"
require "power_trace/stack"

module PowerTrace
  cattr_accessor :replace_backtrace, instance_accessor: false
  cattr_accessor :colorize_backtrace, instance_accessor: false
  self.replace_backtrace = false
  self.colorize_backtrace = true

  def power_trace(options = {})
    PowerTrace::Stack.new(options)
  end
end

include PowerTrace

require "power_trace/exception_patch"
