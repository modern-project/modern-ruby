# frozen_string_literal: true

require "modern/struct"

module Modern
  module Descriptor
    class Content < Modern::Struct
      Type = Types.Instance(self)

      attribute :media_type, Types::MIMEType
      attribute :type, (Types::Type | Types::Struct).optional.default(nil)
    end
  end
end
