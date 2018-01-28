# frozen_string_literal: true

require "modern/struct"

module Modern
  class Descriptor
    class Response < Modern::Struct
      attribute :http_code, Modern::Types::Strict::Int | Modern::Types.Value(:default)
      attribute :description, Modern::Types::Strict::String.optional
    end
  end
end
