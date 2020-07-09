require "power_trace/helpers/colorize_helper"
require "active_support/core_ext/string"

module PowerTrace
  class Entry
    include ColorizeHelper
    UNDEFINED = "[undefined]"

    INDENT = "\s" * 4

    attr_reader :frame, :filepath, :line_number, :receiver, :locals, :arguments

    def initialize(frame)
      @frame = frame
      @filepath = frame.eval("__FILE__")
      @line_number = frame.eval("__LINE__")
      @receiver = frame.receiver
      @locals, @arguments = colloct_locals_and_arguments
    end

    def name(options = {})
      frame.frame_description
    end

    def location(options = {})
      "#{filepath}:#{line_number}"
    end

    def arguments_string(options = {})
      hash_to_string(arguments, false, options[:line_limit])
    end

    def locals_string(options = {})
      hash_to_string(locals, false, options[:line_limit])
    end

    def call_trace(options = {})
      "#{location(options)}:in `#{name(options)}'"
    end

    ATTRIBUTE_COLORS = {
      name: COLORS[:blue],
      location: COLORS[:green],
      arguments_string: COLORS[:orange],
      locals_string: COLORS[:megenta]
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
      assemble_string(options)
    end

    private

    def assemble_string(options)
      strings = [call_trace(options)]

      if arguments.present?
        strings << <<~STR.chomp
            (Arguments)
        #{arguments_string(options)}
        STR
      end

      if locals.present?
        strings << <<~STR.chomp
            (Locals)
        #{locals_string(options)}
        STR
      end

      strings.join("\n")
    end

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

    def colloct_locals_and_arguments
      locals = {}
      arguments = {}

      frame.local_variables.each do |name|
        value = frame.local_variable_get(name)

        if method_parameters.include?(name)
          arguments[name] = value
        else
          locals[name] = value
        end
      end

      [locals, arguments]
    end
  end
end

require "power_trace/entries/method_entry"
require "power_trace/entries/block_entry"
