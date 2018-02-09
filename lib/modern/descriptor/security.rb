# frozen_string_literal: true

require "modern/errors/web_errors"

require "modern/struct"

module Modern
  module Descriptor
    module Security
      class Base < Modern::Struct
        Type = Types.Instance(self)

        attribute :description, Types::Strict::String.optional.default(nil)
      end
    end
  end
end
