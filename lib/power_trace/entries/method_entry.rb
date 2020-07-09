module PowerTrace
  class MethodEntry < Entry
    def method_name
      @frame.frame_description
    end

    def method
      @method ||= Object.instance_method(:method).bind(@receiver).call(method_name)
    end

    def arguments
      @arguments ||= frame.local_variables.each_with_object({}) do |name, args|
        args[name] = frame.local_variable_get(name) if method_parameters.include?(name)
      end
    end

    def method_parameters
      method.parameters.map { |parameter| parameter[1] }
    end

    def defined_class
      method.owner
    end

    def is_private_call?
      method.owner.private_method_defined?(method_name)
    end
  end
end
