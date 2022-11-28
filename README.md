# Metaprogramming with Ruby

This project is a set of examples that illustrate the possibilities of metaprogramming in the Ruby language.

Examples:
- [Memoization](#memoization)
- [Object attributes](#object-attributes)
- [Submodules inclusion](#submodules-inclusion)

## Memoization

To memoize the result of the first method call, just add `memoize` method like this:

```ruby
class Example
  extend Memoize

  memoize def foo
    rand
  end
end
```
To put the result in an instance variable, add option `:as`:

```ruby
memoize def foo
  rand
end, as: :@foo_cached
```
Module `Memoize` also provides memoization of method call with arguments:

```ruby
memoize def foo(x, y)
  rand + x + y
end
```
But there is no possibility to use arguments memoization with option `:as`

```ruby
memoize def foo(x, y)
  rand + x + y
end, as: :@foo_cached

#=> can't memoize in variable when method has any args! (ArgumentError)
```
## Object attributes

Example of DSL:

```ruby
class Example
  extend Attributes

  define_attributes do
    name { required! }

    state do
      enum %i[pending running stopped failed]
      default :pending
    end

    started_at { default { Time.now } }

    count do
      actions do
        incr! do
          @count += 1
        end

        decr! do
          @count -= 1
        end
      end
    end
  end
end
```
Module `Attributes` provides set of methods:

`define_attributes` - main entry point.

```ruby
extend Attributes

define_attributes do
  #
end
```

`required!` - create requirement of attribute (`name` in example) for object initializing.

```ruby
name { required! }

#> Example.new() => Attribute 'name' is required! (ArgumentError)
```

`default` - sets default value (static value or block) for attribute.

```ruby
count { default 3 }
started_at { default { Time.now } }

#> e = Example.new(name: 'test')
#> e.count => 3
#> e.started_at => 2020-12-01 12:55:44.396843523 +0300
```

`enum` - creates public methods (getter, setter) from values in array.

```ruby
state { enum %i[pending finished] }
state { default :pending}

#> e = Example.new(name: 'test')
#> e.state => :pending
#> e.finished? => :false
#> e.finished!
#> e.finished? => true
#> e.state => :finished
```

`actions` - creates public methods for object.

```ruby
count do
  default 0

  actions do
    incr! do
      @count += 1
    end
  end
end

#> e = Example.new(name: 'test')
#> e.count => 0
#> e.incr!
#> e.count => 1
```

## Submodules inclusion

The same functionality as `Object atrributes`. But provides separate submodules inclusion:

```ruby
Name = Attributes.define do
  name { required! }
end

State = Attributes.define do
  state do
    default :pending
    enum %i[started pending finished]
  end
end

class Example
  include Name
  include State
end
```