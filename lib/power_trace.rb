require "power_trace/version"
require "power_trace/stack"

module PowerTrace
  def power_trace
    puts(PowerTrace::Stack.new.to_s)
  end
end

include PowerTrace
