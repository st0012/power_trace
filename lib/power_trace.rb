require "power_trace/version"
require "power_trace/stack"

module PowerTrace
  def power_trace
    PowerTrace::Stack.new
  end
end

include PowerTrace
