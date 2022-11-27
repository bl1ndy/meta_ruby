module Attributes
  class Builder
    attr_reader :attributes, :required_attributes, :defaults

    def initialize(context)
      @context = context
      @attributes = []
      @required_attributes = []
      @defaults = {}
      @actions = {}
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
        @actions["#{value}?".to_sym] = Proc.new { __send__(attr) == value.to_sym }
        @actions["#{value}!".to_sym] = Proc.new { instance_variable_set("@#{attr}".to_sym, value.to_sym) }
      end
    end

    def actions(&block)
      instance_exec(&block)
    end

    def init
      builder = self

      @context.define_method(:initialize) do |**args|
        builder.attributes.each do |attr|
          default = builder.defaults[attr]
          value = args.fetch(attr) do
            default.is_a?(Proc) ? default.call : default
          end
          
          instance_variable_set("@#{attr}".to_sym, value)
          self.class.attr_reader(attr)
  
          raise ArgumentError, "Attribute '#{attr}' is required!" if builder.required_attributes.include?(attr) && !args[attr]
        end
      end

      @actions.each do |name, block|
        @context.define_method(name, &block)
      end
    end

    def method_missing(name, &block)
      @actions[name] = block
    end
  end
end
