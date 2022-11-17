# frozen_string_literal: true

class Example
  extend Memoize

  memoize def foo
    rand
  end

  memoize def foo2
    rand + 1
  end

  memoize def bar
    rand
  end, as: :@bar_cached

  memoize def buz(x, y)
    rand + x + y
  end
end
