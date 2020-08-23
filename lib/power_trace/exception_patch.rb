class StandardError
  attr_accessor :stored_power_trace
end

# the purposes of this section are:
# 1. capture and store a power_trace when the exception is firstly raised (will skip re-raising conditions)
# 2. if `replace_backtrace` is set to `true, it'll use the captured power_trace to replace the exception's original backtrace
TracePoint.trace(:raise) do |tp|
  begin
    e = tp.raised_exception

    # it's too risky to deal with non-StandardError exceptions
    next unless e.is_a?(StandardError)

    # ignore re-raised exceptions
    next if e.stored_power_trace

    # these errors are commonly used as flow control so working with them can be error-prone and slow
    # we can revisit them once the gem gets more stable
    next if e.is_a?(LoadError)
    next if e.is_a?(NameError) && !e.is_a?(NoMethodError)
    next if e.is_a?(SystemCallError)

    if defined?(Bootsnap)
      next if e.is_a?(Bootsnap::LoadPathCache::FallbackScan)
      next if e.is_a?(Bootsnap::LoadPathCache::ReturnFalse)
    end

    e.stored_power_trace = power_trace(exception: true)

    if PowerTrace.replace_backtrace
      e.set_backtrace(
        e.stored_power_trace.to_backtrace
      )
    end
  rescue => e
    PowerTrace.print_power_trace_error(e)
  end
end
