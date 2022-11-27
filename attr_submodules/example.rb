# frozen_string_literal: true

Name = Attributes.define do
  name { required! }
end

State = Attributes.define do
  state do
    default :pending
    enum %i[started pending finished]
  end

  started_at { default { Time.now } }

  count do
    required!
    actions do
      incr! do
        @count += 1
      end
    end
  end
end

class Example
  include Name
  include State
end
