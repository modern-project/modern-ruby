# frozen_string_literal: true

require "modern/struct"

module Modern
  module Descriptor
    class RequestBody < Modern::Struct
      Type = Modern::Types.Instance(self)

      attribute :type, Modern::Types::Type.optional.default(nil)
      attribute :required, Modern::Types::Strict::Bool.default(false)
      attribute :description, Modern::Types::Strict::String.optional.default(nil)
    end
  end
end
