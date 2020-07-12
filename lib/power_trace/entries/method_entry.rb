module PowerTrace
  class MethodEntry < Entry
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

    def defined_class
      method.owner
    end
  end
end
