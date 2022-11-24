module Attributes
  class Builder
    attr_reader :attributes, :required_attributes, :defaults

    def initialize(context)
      @context = context
      @attributes = []
      @required_attributes = []
      @defaults = {}
    end

    def required!
      @required_attributes << attributes.last
    end

    def default(value = nil, &block)
      defaults[attributes.last] = value || block
    end

    def enum(values)
      attr = attributes.last

      values.each do |value|
        @context.define_method("#{value}?".to_sym) do
          __send__(attr) == value.to_sym
        end

        @context.define_method("#{value}!".to_sym) do
          instance_variable_set("@#{attr}".to_sym, value.to_sym)
        end
      end
    end

    def actions(&)
      yield
    end

    def init
      builder = self

      @context.define_method(:initialize) do |**args|
        builder.attributes.each do |attr|
          default = builder.defaults[attr].is_a?(Proc) ? builder.defaults[attr].call : builder.defaults[attr]
          value = args[attr] || default
          
          instance_variable_set("@#{attr}".to_sym, value)
          self.class.attr_reader(attr)
  
          raise ArgumentError, "Attribute '#{attr}' is required!" if builder.required_attributes.include?(attr) && !args[attr]
        end
      end
    end

    def method_missing(name, &block)
      @context.define_method(name) do
        instance_exec(&block)
      end
    end

    def respond_to_missing?(name)
      respond_to?(name)
    end
  end
end
