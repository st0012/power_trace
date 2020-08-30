RSpec::Core::Formatters::ExceptionPresenter.class_eval do
  alias :original_formatted_backtrace :formatted_backtrace

  def formatted_backtrace(exception=@exception)
    backtrace = exception.stored_power_trace.to_backtrace(extra_info_indent: 8)
    backtrace_formatter.format_backtrace(backtrace, example.metadata) + formatted_cause(exception)
  rescue => e
    PowerTrace.print_power_trace_error(e)
    original_formatted_backtrace
  end
end
