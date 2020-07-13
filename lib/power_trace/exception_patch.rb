class StandardError
  attr_accessor :stored_power_trace
end

TracePoint.trace(:raise) do |tp|
  begin
    e = tp.raised_exception

    next unless e.is_a?(StandardError)

    next if e.stored_power_trace

    next if e.is_a?(LoadError)
    next if e.is_a?(NameError)
    next if e.is_a?(SystemCallError)

    if defined?(Bootsnap)
      next if e.is_a?(Bootsnap::LoadPathCache::FallbackScan)
      next if e.is_a?(Bootsnap::LoadPathCache::ReturnFalse)
    end

    e.stored_power_trace = power_trace(exception: true)

    if PowerTrace.replace_backtrace
      e.set_backtrace(
        e.stored_power_trace.to_backtrace(colorize: PowerTrace.colorize_backtrace)
      )
    end
  rescue => e
    puts(e)
    puts(e.backtrace)
    puts("power_trace's BUG")
  end
end
