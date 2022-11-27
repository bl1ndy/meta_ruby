# frozen_string_literal: true

class Attributes < Module
  autoload :Builder, File.join(__dir__, 'builder')
  autoload :DSL, File.join(__dir__, 'dsl')
  autoload :AttributesInitializer, File.join(__dir__, 'attributes_initializer')

  def self.initializer
    @initializer ||= AttributesInitializer.new
  end

  def self.define(&block)
    builder = Builder.new
    proxy = DSL.proxy(builder).new

    proxy.instance_exec(&block)

    new(builder)
  end

  def initialize(builder)
    self.class.initializer.accept(builder)
  end

  def included(base)
    self.class.initializer.init(base)
  end
end
