module PowerTrace
  class BlockEntry < Entry
    def name
      "block in #{frame.eval("__method__")}"
    end

    def method
    end

    def arguments
      @arguments ||= frame.local_variables.each_with_object({}) do |name, args|
        args[name] = frame.local_variable_get(name)
      end
    end

    def defined_class
    end
  end
end
