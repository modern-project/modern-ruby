# frozen_string_literal: true

require 'modern/descriptor/response'
require 'modern/descriptor/content'

require 'docile'

module Modern
  module DSL
    class ResponseBuilder
      attr_reader :value

      def initialize(http_code_or_response)
        @value =
          if http_code_or_response.is_a?(Modern::Descriptor::Response)
            http_code_or_response
          else
            Modern::Descriptor::Response.new(http_code: http_code_or_response)
          end
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

      def self.evaluate(http_code_or_response, &block)
        builder = ResponseBuilder.new(http_code_or_response)
        builder.instance_exec(&block)
        builder.value
      end
    end
  end
end
