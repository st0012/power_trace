require "power_trace/entry"
require "pry-stack_explorer"

module PowerTrace
  class Stack
    include Enumerable

    attr_reader :entries

    def initialize(options = {})
      @output_options = extract_output_options(options)
      @options = options
      @entries = extract_entries
    end

    def each(&block)
      @entries.each(&block)
    end

    def to_s
      @entries.compact.map { |e| e.to_s(@output_options) }.join("\n")
    end

    private

    def extract_output_options(options)
      output_options = { colorize: options.fetch(:colorize, true) }
      options.delete(:colorize)
      output_options
    end

    def frame_manager
      PryStackExplorer.frame_manager(Pry.new)
    end

    def extract_entries
      frames = frame_manager.bindings
      power_trace_index = frames.index { |b| b.frame_description&.to_sym == :power_trace }
      frames[power_trace_index+2..].map do |b|
        case b.frame_type
        when :method
          MethodEntry.new(b)
        when :block
          BlockEntry.new(b)
        end
      end
    end
  end
end
