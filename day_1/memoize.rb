# frozen_string_literal: true

module Memoize
  def memoize(name, as: nil)
    unbound = instance_method(name)
    has_args = unbound.arity.positive?
    cache = {}

    raise ArgumentError, "can't memoize in variable when method has any args!" if as && has_args

    define_method name do |*args|
      if as
        return instance_variable_get(as) if instance_variable_defined?(as)

        instance_variable_set(as, unbound.bind_call(self, *args))
      else
        cache[args] ||= unbound.bind_call(self, *args)
      end
    end
  end
end
