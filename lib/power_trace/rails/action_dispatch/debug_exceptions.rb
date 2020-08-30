module ActionDispatch
  class DebugExceptions
    private

    def log_error(request, wrapper)
      logger = logger(request)

      return unless logger

      exception = wrapper.exception

      trace = wrapper.application_power_trace
      trace = wrapper.framework_power_trace if trace.empty?

      ActiveSupport::Deprecation.silence do
        message = []
        message << "  "
        message << "#{exception.class} (#{exception.message}):"
        message.concat(exception.annotated_source_code) if exception.respond_to?(:annotated_source_code)
        message << "  "
        message.concat(trace)

        log_array(logger, message)
      end
    end
  end
end

