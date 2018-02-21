# frozen_string_literal: true

require "modern/struct"

module Modern
  module Descriptor
    class Server < Modern::Struct
      attribute :url, Modern::Types::Strict::String
      attribute :description, Modern::Types::Strict::String.optional.default(nil)
    end
  end
end
