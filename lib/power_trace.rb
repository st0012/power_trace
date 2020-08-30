require "power_trace/version"
require "power_trace/stack"

module PowerTrace
  cattr_accessor :colorize_backtrace, instance_accessor: false
  self.colorize_backtrace = true

  cattr_accessor :replace_backtrace, instance_accessor: false
  self.replace_backtrace = false

  cattr_accessor :integrations, instance_accessor: false

  cattr_accessor :trace_limit, instance_accessor: false
  self.trace_limit = 50

  def power_trace(options = {})
    PowerTrace::Stack.new(options)
  end

  class << self
    AVAILABLE_INTEGRATIONS = [:rails, :rspec, :minitest].freeze

    def integrations=(integrations)
      integrations = Array(integrations).uniq.map(&:to_sym)

      integrations.each do |integration|
        unless AVAILABLE_INTEGRATIONS.include?(integration)
          raise "#{integration} is not a supported integration, only #{AVAILABLE_INTEGRATIONS} is allowed."
        end

        case integration
        when :rails
          require "power_trace/integrations/rails"
        when :rspec
          require "power_trace/integrations/rspec"
        when :minitest
          require "power_trace/integrations/minitest"
        end
      end

      @@integrations = integrations
    end

    def print_power_trace_error(exception)
      puts(exception)
      puts(exception.backtrace)
      puts("there's a bug in power_trace, please open an issue at https://github.com/st0012/power_trace")
    end
  end
end

include PowerTrace

require "power_trace/exception_patch"

