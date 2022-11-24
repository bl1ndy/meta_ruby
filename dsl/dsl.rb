# frozen_string_literal: true

module Attributes
  module DSL
    def self.proxy(builder)
      Class.new do
        define_method(:method_missing) do |name, &block|
          builder.attributes << name
          builder.instance_exec(&block)
        end

        define_method(:respond_to_missing?) do |name|
          builder.respond_to?(name)
        end
      end
    end
  end
end
