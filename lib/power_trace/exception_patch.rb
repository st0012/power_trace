class Exception
  attr_accessor :power_trace
end

TracePoint.trace(:raise) do |tp|
  begin
    e = tp.raised_exception
    e.power_trace = power_trace
  rescue => e
    puts e
    puts e.backtrace
    fail "power_trace BUG"
  end
end
