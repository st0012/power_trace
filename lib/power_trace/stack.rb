require "power_trace/entry"
require "pry-stack_explorer"

module PowerTrace
  class Stack
    include Enumerable

    attr_reader :entries

    OUTPUT_OPTIONS_DEFAULT = {
      colorize: true,
      line_limit: 100
    }

    def initialize(options = {})
      @options = options
      @exception = options.fetch(:exception, false)
      @entries = extract_entries.compact
    end

    def each(&block)
      @entries.each(&block)
    end

    def to_backtrace(output_options = {})
      output_options = extract_output_options(output_options)
      @entries.map { |e| e.to_s(output_options) }
    end

    def to_s(output_options = {})
      to_backtrace(output_options).join("\n")
    end

    def empty?
      @entries.empty?
    end

    private

    def extract_output_options(options)
      OUTPUT_OPTIONS_DEFAULT.each_with_object({}) do |(option_name, default), output_options|
        output_options[option_name] = options.fetch(option_name, default)
        options.delete(option_name)
      end
    end

    def frame_manager
      PryStackExplorer.frame_manager(Pry.new)
    end

    def extract_entries
      frames = frame_manager.bindings
      # when using pry console, the power_trace_index will be `nil` and breaks EVERYTHING
      # so we should fallback it to 0
      power_trace_index = (frames.index { |b| b.frame_description&.to_sym == :power_trace } || 0) + 1
      power_trace_index += 1 if @exception

      frames[power_trace_index..].map do |b|
        case b.frame_type
        when :method
          MethodEntry.new(b)
        when :block
          BlockEntry.new(b)
        else
          Entry.new(b)
        end
      end
    end
  end
end
