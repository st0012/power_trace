require "power_trace/entry"
require "pry-stack_explorer"

module PowerTrace
  class Stack
    include Enumerable

    def initialize(options = {})
      frame_manager = PryStackExplorer.frame_manager(Pry.new)
      frames = frame_manager.bindings
      power_trace_index = frames.index { |b| b.frame_description&.to_sym == :power_trace }
      @options = options
      @entries = frames[power_trace_index+2..].map do |b|
        case b.frame_type
        when :method
          MethodEntry.new(b)
        when :block
          BlockEntry.new(b)
        end
      end
    end

    def each(&block)
      @entries.each(&block)
    end

    def to_s
      @entries.compact.map { |e| e.to_s(@options) }.join("\n")
    end
  end
end
