# frozen_string_literal: true

require "modern/struct"

module Modern
  module Descriptor
    class Schema < Modern::Struct
      Type = Modern::Types.Instance(self)
    end
  end
end
