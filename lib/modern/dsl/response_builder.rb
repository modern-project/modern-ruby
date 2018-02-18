# frozen_string_literal: true

require 'modern/descriptor/response'
require 'modern/descriptor/content'

require 'docile'

module Modern
  module DSL
    class ResponseBuilder
      attr_reader :value

      def initialize(http_code)
        @value = Modern::Descriptor::Response.new(http_code: http_code)
      end

      def description(s)
        @value = @value.copy(description: s)
      end

      def content(media_type, type = nil)
        raise "Duplicate content type: #{media_type}" \
          if @value.content.any? { |c| c.media_type.casecmp(media_type).zero? }

        new_content = Modern::Descriptor::Content.new(media_type: media_type, type: type)
        @value = @value.copy(content: @value.content + [new_content])
      end

      def self.evaluate(http_code, &block)
        builder = ResponseBuilder.new(http_code)
        Docile.dsl_eval(builder, &block)
        builder.value
      end
    end
  end
end
