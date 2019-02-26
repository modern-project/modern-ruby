# frozen_string_literal: true

require "modern/struct"
require "modern/descriptor/content"
require "modern/descriptor/parameters"

module Modern
  module Descriptor
    class Response < Modern::Struct
      # TODO: figure out a good way to handle header responses
      #       This is in part an API response type of thing; how do we ensure that
      #       an action defines the header that it says it's defining?
      attribute :http_code, Types::Strict::Integer | Types.Value(:default)
      attribute :description, Types::Strict::String.default("No description provided.")
      attribute :content, Types.array_of(Content)

      attr_reader :content_by_type

      def initialize(fields)
        super

        @content_by_type = content.map { |c| [c.media_type, c] }.to_h.freeze
      end
    end
  end
end
