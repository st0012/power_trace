RSpec::Core::Formatters::ExceptionPresenter.class_eval do
  alias :original_formatted_backtrace :formatted_backtrace

  def formatted_backtrace(exception=@exception)
    if PowerTrace.power_rspec_trace || PowerTrace.replace_backtrace
      backtrace = exception.stored_power_trace.to_backtrace(extra_info_indent: 8)
      backtrace_formatter.format_backtrace(backtrace, example.metadata) + formatted_cause(exception)
    else
      original_formatted_backtrace
    end
  rescue => e
    puts(e)
    puts(e.backtrace)
    puts("there's a bug in power_trace, please open an issue at https://github.com/st0012/power_trace")
    original_formatted_backtrace
  end
end
