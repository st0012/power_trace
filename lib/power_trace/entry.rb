require "power_trace/helpers/colorize_helper"

module PowerTrace
  class Entry

    include ColorizeHelper
    UNDEFINED = "[undefined]"

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
      generate_string_result(arguments, false)
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
            <= #{arguments_string(options)}
        MSG
      else
        call_trace(options)
      end
    end

    private

    def generate_string_result(obj, inspect)
      case obj
      when Array
        array_to_string(obj, inspect)
      when Hash
        hash_to_string(obj, inspect)
      when UNDEFINED
        UNDEFINED
      when String
        "\"#{obj}\""
      when nil
        "nil"
      else
        inspect ? obj.inspect : obj.to_s
      end
    end

    def array_to_string(array, inspect)
      elements_string = array.map do |elem|
        generate_string_result(elem, inspect)
      end.join(", ")
      "[#{elements_string}]"
    end

    def hash_to_string(hash, inspect)
      elements_string = hash.map do |key, value|
        "#{key.to_s}: #{generate_string_result(value, inspect)}"
      end.join(", ")
      "{#{elements_string}}"
    end

    def obj_to_string(element, inspect)
      to_string_method = inspect ? :inspect : :to_s

      if !inspect && element.is_a?(String)
        "\"#{element}\""
      else
        element.send(to_string_method)
      end
    end

  end
end

require "power_trace/entries/method_entry"
require "power_trace/entries/block_entry"
