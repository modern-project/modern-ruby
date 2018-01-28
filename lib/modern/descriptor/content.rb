# frozen_string_literal: true

require "modern/struct"

module Modern
  module Descriptor
    class Content < Modern::Struct
      Type = Modern::Types.Instance(self)

      attribute :media_type, Modern::Types::MIMEType
      attribute :schema, Modern::Descriptor::Schema::Type.optional.default(nil)
    end
  end
end
