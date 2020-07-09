module PowerTrace
  class Entry
    UNDEFINED = "[undefined]"

    COLOR_CODES = {
      green: 10,
      yellow: 11,
      blue: 12,
      megenta: 13,
      cyan: 14,
      orange: 214
    }

    attr_reader :frame, :filepath, :line_number, :receiver

    def initialize(frame)
      @frame = frame
      @filepath = frame.eval("__FILE__")
      @line_number = frame.eval("__LINE__")
      @receiver = frame.receiver
    end

    def call_trace
      "#{filepath}:#{line_number}:in `#{name}'"
    end

    def to_s(options = {})
      if !arguments.empty?
        <<~MSG.chomp
          #{call_trace}
            <= #{arguments_string}
        MSG
      else
        call_trace
      end
    end

    def arguments_string
      generate_string_result(arguments, false)
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
