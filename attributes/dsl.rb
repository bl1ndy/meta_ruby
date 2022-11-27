# frozen_string_literal: true

module Attributes
  module DSL
    def self.proxy(builder)
      Class.new do
        define_method(:method_missing) do |name, &block|
          builder.attributes << name
          builder.instance_exec(&block)
        end
      end
    end
  end
end
