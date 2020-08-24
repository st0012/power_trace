require "power_trace/helpers/colorize_helper"
require "active_support/core_ext/string"

module PowerTrace
  class Entry
    include ColorizeHelper
    UNDEFINED = "[undefined]"
    EMPTY_STRING = ""
    SPACE = "\s"
    DEFAULT_LINE_LIMIT = 100

    attr_reader :frame, :filepath, :line_number, :receiver, :locals, :arguments

    def initialize(frame)
      @frame = frame
      @filepath, @line_number = frame.source_location
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
      <<~STR.chomp
        #{options[:indentation]}(Arguments)
        #{hash_to_string(arguments, false, options)}
      STR
    end

    def locals_string(options = {})
      <<~STR.chomp
        #{options[:indentation]}(Locals)
        #{hash_to_string(locals, false, options)}
      STR
    end

    def call_trace(options = {})
      "#{location(options)}:in `#{name(options)}'"
    end

    ATTRIBUTE_COLORS = {
      name: :blue,
      location: :green,
      arguments_string: :orange,
      locals_string: :megenta
    }

    ATTRIBUTE_COLORS.each do |attribute, color|
      alias_method "original_#{attribute}".to_sym, attribute

      # regenerate attributes with `colorize: true` support
      define_method attribute do |options = {}|
        call_result = send("original_#{attribute}", options)

        if options[:colorize]
          send("#{color}_color", call_result)
        else
          call_result
        end
      end
    end

    def to_s(options = {})
      # this is to prevent entries from polluting each other's options
      # of course, that'd only happen if I did something stupid ;)
      assemble_string(options.dup)
    end

    private

    def method_parameters
      []
    end

    def assemble_string(options)
      strings = [call_trace(options)]

      indentation = SPACE * (options[:extra_info_indent] || 0)
      options[:indentation] = indentation

      if arguments.present?
        strings << arguments_string(options)
      end

      if locals.present?
        strings << locals_string(options)
      end

      strings.join("\n")
    end

    def hash_to_string(hash, inspect, options)
      truncation = options[:line_limit] || DEFAULT_LINE_LIMIT
      indentation = (options[:indentation] || EMPTY_STRING) + SPACE * 2

      elements_string = hash.map do |key, value|
        value_string = value_to_string(value, truncation)
        "#{key.to_s}: #{value_string}"
      end.join("\n#{indentation}")
      "#{indentation}#{elements_string}"
    end

    def value_to_string(value, truncation)
      case value
      when Array
        value.to_s.truncate(truncation, omission: "...]")
      when Hash
        value.to_s.truncate(truncation, omission: "...}")
      when nil
        "nil"
      when Symbol
        ":#{value}"
      when String
        "\"#{value.truncate(truncation)}\""
      else
        if defined?(ActiveRecord::Base) && value.is_a?(ActiveRecord::Base)
          value.inspect.truncate(truncation, omission: "...>")
        else
          value.to_s.truncate(truncation)
        end
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

    def method
      @method ||= Object.instance_method(:method).bind(@receiver).call(name)
    rescue NameError
      # if any part of the program uses Refinement to extend its methods
      # we might still get NoMethodError when trying to get that method outside the scope
      nil
    end

    private

    def method_parameters
      if method
        method.parameters.map { |parameter| parameter[1] }
      else
        []
      end
    end
  end
end
