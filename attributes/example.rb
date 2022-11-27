# frozen_string_literal: true

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
      default 0

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

# При отсутствии атрибута, помеченного как required! выдавать ошибку ArgumentError:
# Example.new(state: :running) => ArgumentError

# Действия, перечисленные в actions должны быть преобразованы в методы объекта:
# f.incr!
# f.count => 1
# f.decr!
# f.count => 0

# default может принимать статичное значение или блок, выполняющийся при инициализации объекта
# f = Example.new(name: 'test')
# f.started_at => 2022-12-01 13:43:18 +0300

# enum создает методы проверки текущего состояния и его изменения
# f.state => :pending
# f.pending? => true
# f.running? => false
# f.running!
# f.running? => true
