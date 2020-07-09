module PowerTrace
  class MethodEntry < Entry
    def method
      @method ||= Object.instance_method(:method).bind(@receiver).call(name)
    end

    def method_parameters
      method.parameters.map { |parameter| parameter[1] }
    end

    def defined_class
      method.owner
    end
  end
end
