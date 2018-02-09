# frozen_string_literal: true

require "modern/struct"

module Modern
  module Descriptor
    class RequestBody < Modern::Struct
      Type = Types.Instance(self)

      attribute :type, (Types::Type | Types::Struct).optional.default(nil)
      attribute :required, Types::Strict::Bool.default(false)
      attribute :description, Types::Strict::String.optional.default(nil)
    end
  end
end
