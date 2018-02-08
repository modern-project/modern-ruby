# frozen_string_literal: true

require "modern/struct"
require "modern/descriptor/content"

module Modern
  module Descriptor
    class Response < Modern::Struct
      Type = Modern::Types.Instance(self)

      module Types
        HttpCode = Modern::Types::Strict::Int | Modern::Types.Value(:default)
      end

      class Header < Modern::Struct
        Type = Modern::Types.Instance(self)

        attribute :name, Modern::Types::Strict::String
        attribute :description, Modern::Types::Strict::String.optional.default(nil)
        attribute :schema, Modern::Types::Type.optional.default(nil)
      end

      attribute :http_code, Types::HttpCode
      attribute :description, Modern::Types::Strict::String.optional.default(nil)
      attribute :headers, Modern::Types.array_of(Header::Type)
      attribute :content, Modern::Types.array_of(Content::Type)

      attr_reader :content_by_type

      def initialize(fields)
        super

        @content_by_type = content.map { |c| [c.media_type, c] }.to_h.freeze
      end
    end
  end
end
