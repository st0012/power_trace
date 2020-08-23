module Minitest
  class UnexpectedError
    alias :original_backtrace :backtrace

    def backtrace
      if PowerTrace.power_minitest_trace
        begin
          error.stored_power_trace.to_backtrace(extra_info_indent: 8)
        rescue => e
          PowerTrace.print_power_trace_error(e)
          original_backtrace
        end
      else
        original_backtrace
      end
    end
  end
end
