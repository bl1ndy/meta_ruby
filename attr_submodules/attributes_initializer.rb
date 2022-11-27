# frozen_string_literal: true

class AttributesInitializer
  def initialize
    @options = {
      attributes: [],
      required_attributes: [],
      actions: {},
      defaults: {}
    }
  end

  def accept(builder)
    @options[:attributes].push(*builder.attributes)
    @options[:required_attributes].push(*builder.required_attributes)
    @options[:defaults] = @options[:defaults].merge(builder.defaults)
    @options[:actions] = @options[:actions].merge(builder.actions_list)
  end

  def init(base)
    options = @options

    base.define_method(:initialize) do |**args|
      options[:attributes].each do |attr|
        default = options[:defaults][attr]
        value = args.fetch(attr) do
          default.is_a?(Proc) ? default.call : default
        end

        instance_variable_set("@#{attr}".to_sym, value)
        self.class.attr_reader(attr)

        if options[:required_attributes].include?(attr) && !args[attr]
          raise ArgumentError, "Attribute '#{attr}' is required!"
        end
      end
    end

    options[:actions].each do |name, block|
      base.define_method(name, &block)
    end
  end
end
