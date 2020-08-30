require "power_trace/helpers/colorize_helper"
require "active_support/core_ext/string"

module PowerTrace
  class Entry
    include ColorizeHelper
    UNDEFINED = "[undefined]"
    EMPTY_STRING = ""
    EMPTY_ARRAY = [].freeze
    EMPTY_HASH = {}.freeze
    SET_IVAR_INSTRUCTION_REGEX = /setinstancevariable/
    SPACE = "\s"
    DEFAULT_LINE_LIMIT = 100

    attr_reader :frame, :filepath, :line_number, :receiver, :locals, :arguments, :ivars

    def initialize(frame)
      @frame = frame
      @filepath, @line_number = frame.source_location
      @receiver = frame.receiver
      @locals, @arguments = collect_locals_and_arguments
      @ivars = collect_ivars
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

    def ivars_string(options = {})
      <<~STR.chomp
        #{options[:indentation]}(Instance Variables)
        #{hash_to_string(ivars, false, options)}
      STR
    end

    def call_trace(options = {})
      "#{location(options)}:in `#{name(options)}'"
    end

    ATTRIBUTE_COLORS = {
      name: :blue,
      location: :green,
      arguments_string: :orange,
      locals_string: :megenta,
      ivars_string: :cyan
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

      if ivars.present?
        strings << ivars_string(options)
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
        elements_string = value.map do |key, val|
          value_string = value_to_string(val, truncation)
          "#{key.to_s}: #{value_string}"
        end.join(", ")

        "{#{elements_string}}".truncate(truncation, omission: "...}")
      when nil
        "nil"
      when Symbol
        ":#{value}"
      when String
        "\"#{value.truncate(truncation)}\""
      else
        if defined?(ActiveRecord::Base)
          case value
          when ActiveRecord::Base
            value.inspect.truncate(truncation, omission: "...>")
          when ActiveRecord::Relation
            "#{value}, SQL - (#{value.to_sql})"
          else
            value.to_s.truncate(truncation)
          end
        else
          value.to_s.truncate(truncation)
        end
      end
    end

    # we need to make sure
    # 1. the frame is iseq (vm instructions)
    # 2. and the instructions contain `setinstancevariable` instructions
    #
    # and only then we can start capturing instance variables from the frame
    # this is to make sure we only capture the instance variables set inside the current method call
    # otherwise, it'll create a lot noise
    def collect_ivars
      iseq = frame.instance_variable_get(:@iseq)

      return EMPTY_HASH unless iseq

      set_ivar_instructios = iseq.disasm.split("\n").select { |i| i.match?(SET_IVAR_INSTRUCTION_REGEX) }

      return EMPTY_HASH unless set_ivar_instructios.present?

      new_ivars = set_ivar_instructios.map do |i|
        i.match(/:(@\w+),/)[1]
      end

      new_ivars.inject({}) do |hash, ivar_name|
        hash[ivar_name] = receiver.instance_variable_get(ivar_name.to_sym)
        hash
      end
    end

    def collect_locals_and_arguments
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
        EMPTY_ARRAY
      end
    end
  end
end
