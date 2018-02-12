# frozen_string_literal: true

require "modern/struct"
require "modern/descriptor/content"

module Modern
  module Descriptor
    class Response < Modern::Struct
      Type = Types.Instance(self)

      class Header < Modern::Struct
        # TODO: rename #schema to #type and implement in OpenAPI generator
        Type = Types.Instance(self)

        attribute :name, Types::Strict::String
        attribute :description, Types::Strict::String.optional.default(nil)
        attribute :schema, Types::Type.optional.default(nil)
      end

      attribute :http_code, Types::Strict::Int | Types.Value(:default)
      attribute :description, Types::Strict::String.default("No description provided.")
      attribute :headers, Types.array_of(Header::Type)
      attribute :content, Types.array_of(Content::Type)

      attr_reader :content_by_type

      def initialize(fields)
        super

        @content_by_type = content.map { |c| [c.media_type, c] }.to_h.freeze
      end
    end
  end
end
