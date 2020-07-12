RSpec::Core::Formatters::ExceptionPresenter.class_eval do
  alias :original_formatted_backtrace :formatted_backtrace

  def formatted_backtrace(exception=@exception)
    if PowerTrace.adjust_rspec_error || PowerTrace.replace_backtrace
      backtrace_formatter.format_backtrace(exception.power_trace.to_backtrace(extra_info_indent: 8), example.metadata) +
        formatted_cause(exception)
    else
      original_formatted_backtrace
    end
  end
end
