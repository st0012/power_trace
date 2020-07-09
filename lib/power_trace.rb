require "power_trace/version"
require "power_trace/stack"

module PowerTrace
  def power_trace(options = {})
    PowerTrace::Stack.new(options)
  end
end

include PowerTrace

require "power_trace/exception_patch"
