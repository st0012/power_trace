require "power_trace/helpers/colorize_helper"
require "active_support/core_ext/string"

module PowerTrace
  class Entry

    include ColorizeHelper
    UNDEFINED = "[undefined]"

    INDENT = "\s" * 4

    attr_reader :frame, :filepath, :line_number, :receiver

    def initialize(frame)
      @frame = frame
      @filepath = frame.eval("__FILE__")
      @line_number = frame.eval("__LINE__")
      @receiver = frame.receiver
    end

    def location(options = {})
      "#{filepath}:#{line_number}"
    end

    def arguments_string(options = {})
      hash_to_string(arguments, false, options[:line_limit])
    end

    def call_trace(options = {})
      "#{location(options)}:in `#{name(options)}'"
    end

    ATTRIBUTE_COLORS = {
      method: COLORS[:blue],
      location: COLORS[:green],
      arguments_string: COLORS[:orange]
    }

    ATTRIBUTE_COLORS.each do |attribute, color|
      alias_method "original_#{attribute}".to_sym, attribute

      # regenerate attributes with `colorize: true` support
      define_method attribute do |options = {}|
        call_result = send("original_#{attribute}", options)

        if options[:colorize]
          "#{color}#{call_result}#{COLORS[:reset]}"
        else
          call_result
        end
      end
    end

    def to_s(options = {})
      if !arguments.empty?
        <<~MSG.chomp
          #{call_trace(options)}
            Arguments:
          #{arguments_string(options)}
        MSG
      else
        call_trace(options)
      end
    end

    private

    def hash_to_string(hash, inspect, truncation)
      elements_string = hash.map do |key, value|
        value_string = value_to_string(value, truncation)
        "#{key.to_s}: #{value_string}"
      end.join("\n#{INDENT}")
      "#{INDENT}#{elements_string}"
    end

    def value_to_string(value, truncation)
      case value
      when Array
        value.to_s.truncate(truncation, omission: "...]")
      when Hash
        value.to_s.truncate(truncation, omission: "...}")
      when nil
        "nil"
      else
        value.to_s.truncate(truncation)
      end
    end
  end
end

require "power_trace/entries/method_entry"
require "power_trace/entries/block_entry"
