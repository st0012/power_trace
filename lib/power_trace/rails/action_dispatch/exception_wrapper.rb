module ActionDispatch
  class ExceptionWrapper
    def application_power_trace
      clean_power_trace(:silent)
    end

    def framework_power_trace
      clean_power_trace(:noise)
    end

    def full_power_trace
      clean_power_trace(:all)
    end

    private
      def stored_power_trace
        Array(@exception.stored_power_trace.map { |t| t.to_s(extra_info_indent: 4) })
      end

      def clean_power_trace(*args)
        if backtrace_cleaner
          backtrace_cleaner.clean(stored_power_trace, *args)
        else
          stored_power_trace
        end
      end
  end
end
