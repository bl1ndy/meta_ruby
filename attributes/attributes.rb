# frozen_string_literal: true

module Attributes
  autoload :Builder, File.join(__dir__, 'builder')
  autoload :DSL, File.join(__dir__, 'dsl')

  def define_attributes(&block)
    context = block.binding.eval('self')
    builder = Builder.new(context)

    proxy = DSL.proxy(builder).new
    proxy.instance_exec(&block)

    builder.init
  end
end
