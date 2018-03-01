# frozen_string_literal: true

require 'modern/descriptor/route'

require 'modern/dsl/response_builder'

require 'docile'

module Modern
  module DSL
    class RouteBuilder
      attr_reader :value

      def initialize(id, http_method, path, settings)
        new_path_segments = path&.split("/") || []
        @value = Modern::Descriptor::Route.new(
          id: id.to_s,
          path: "/" + ([settings.path_segments] + new_path_segments).flatten.compact.join("/"),
          http_method: http_method.upcase,
          summary: nil,
          description: nil,
          deprecated: settings.deprecated,
          tags: settings.tags,
          parameters: settings.parameters,
          request_body: nil,
          responses: [settings.default_response],
          input_converters: settings.input_converters,
          output_converters: settings.output_converters,
          security: settings.security,
          helpers: settings.helpers,
          action: proc {}
        )
      end

      def summary(s)
        @value = @value.copy(summary: s)
      end

      def description(s)
        @value = @value.copy(description: s)
      end

      def deprecate!
        @value = @value.copy(deprecated: true)
      end

      def tag(s)
        @value = @value.copy(tags: @value.tags + [s])
      end

      def parameter(name, parameter_type, opts)
        param = Modern::Descriptor::Parameters.from_inputs(name, parameter_type, opts)
        raise "Duplicate parameter '#{name}'.'" if @value.parameters.any? { |p| p.name.casecmp(param.name).zero? }

        @value = @value.copy(parameters: @value.parameters + [param])
      end

      def request_body(type, opts = { required: true })
        opts = { required: true }.merge(opts).merge(type: type)
        @value = @value.copy(request_body: Modern::Descriptor::RequestBody.new(opts))
      end

      def response(http_code, &block)
        existing_response = @value.responses.find { |r| r.http_code == http_code }

        resp = ResponseBuilder.evaluate(existing_response || http_code, &block)
        @value = @value.copy(responses: @value.responses + [resp])
      end

      def input_converter(media_type_or_converter, &block)
        if media_type_or_converter.is_a?(Modern::Descriptor::Converters::Input::Base)
          @value = @value.copy(input_converters: @value.input_converters + [media_type_or_converter])
        elsif media_type_or_converter.is_a?(String) && !block.nil?
          input_converter(
            Modern::Descriptor::Converters::Input::Base.new(
              media_type: media_type_or_converter, converter: block
            )
          )
        else
          raise "must pass a String and block or a Modern::Descriptor::Converters::Input::Base."
        end
      end

      def clear_input_converters!
        @value = @value.copy(input_converters: [])
      end

      def output_converter(media_type_or_converter, &block)
        if media_type_or_converter.is_a?(Modern::Descriptor::Converters::Output::Base)
          @value = @value.copy(output_converters: @value.output_converters + [media_type_or_converter])
        elsif media_type_or_converter.is_a?(String) && !block.nil?
          output_converter(
            Modern::Descriptor::Converters::Output::Base.new(
              media_type: media_type_or_converter, converter: block
            )
          )
        else
          raise "must pass a String and block or a Modern::Descriptor::Converters::Output::Base."
        end
      end

      def clear_output_converters!
        @value = @value.copy(output_converters: [])
      end

      def clear_security!
        @value = @value.copy(security: [])
      end

      def security(sec)
        @value = @value.copy(security: @value.security + [sec])
      end

      def helper(h)
        @value = @value.copy(helpers: @value.helpers + [h])
      end

      def action(&block)
        @value = @value.copy(action: block)
      end

      def self.evaluate(id, http_method, path, settings, &block)
        builder = RouteBuilder.new(id, http_method, path, settings)
        builder.instance_exec(&block)

        builder.value
      end
    end
  end
end
