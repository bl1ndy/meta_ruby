# frozen_string_literal: true

class Builder
  attr_reader :attributes, :required_attributes, :defaults, :actions_list

  def initialize
    @attributes = []
    @required_attributes = []
    @defaults = {}
    @actions_list = {}
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
      actions_list["#{value}?".to_sym] = proc { __send__(attr) == value.to_sym }
      actions_list["#{value}!".to_sym] = proc { instance_variable_set("@#{attr}".to_sym, value.to_sym) }
    end
  end

  def actions(&block)
    instance_exec(&block)
  end

  def method_missing(name, &block)
    @actions_list[name] = block
  end
end
