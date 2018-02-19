# frozen_string_literal: true

require 'modern/struct'

require 'modern/capsule'
require 'modern/descriptor'

require 'modern/dsl/scope_settings'

require 'deep_dup'
require 'docile'
require 'ice_nine'

module Modern
  module DSL
    class Scope
      attr_reader :descriptor

      def initialize(descriptor, settings = nil)
        @descriptor = descriptor
        @settings = settings || ScopeSettings.new
      end

      def capsule(cap)
        raise "Must be a Modern::Capsule." unless cap.is_a?(Modern::Capsule)
        @descriptor = _scope({}, &cap.block)
      end

      def path(p, &block)
        @descriptor = _scope(path_segments: @settings.path_segments + p.split("/"), &block)
      end

      def default_response(&block)
        resp = ResponseBuilder.evaluate(@settings.default_response, &block)
        @settings = @settings.copy(default_response: resp)
      end

      def deprecate!
        @settings = @settings.copy(deprecated: true)
      end

      def tag(t)
        @settings = @settings.copy(tags: @settings.tags + [t.to_s])
      end

      def helper(h)
        @settings = @settings.copy(helpers: @settings.helpers + [h])
      end

      def parameter(name, parameter_type, opts)
        param = Modern::Descriptor::Parameters.from_inputs(name, parameter_type, opts)
        raise "Duplicate parameter '#{name}'.'" if @settings.parameters.any? { |p| p.name == param.name }

        @settings = @settings.copy(parameters: @settings.parameters + [param])
      end

      def clear_security!
        @settings = @settings.copy(security: [])
      end

      def security(sec)
        @settings = @settings.copy(security: @settings.security + [sec])
      end

      def input_converter(media_type_or_converter, &block)
        if media_type_or_converter.is_a?(Modern::Descriptor::Converters::Input::Base)
          @settings = @settings.copy(input_converters: @settings.input_converters + [media_type_or_converter])
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

      def output_converter(media_type_or_converter, &block)
        if media_type_or_converter.is_a?(Modern::Descriptor::Converters::Output::Base)
          @settings = @settings.copy(output_converters: @settings.output_converters + [media_type_or_converter])
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

      def route(id, http_method, path = nil, &block)
        route = RouteBuilder.evaluate(id, http_method, path, @settings, &block)
        @descriptor = @descriptor.copy(routes: @descriptor.routes + [route])
      end

      def get(id, path = nil, &block)
        route(id, :get, path, &block)
      end

      def post(id, path = nil, &block)
        route(id, :post, path, &block)
      end

      def put(id, path = nil, &block)
        route(id, :put, path, &block)
      end

      def delete(id, path = nil, &block)
        route(id, :delete, path, &block)
      end

      def patch(id, path = nil, &block)
        route(id, :patch, path, &block)
      end

      def self.evaluate(descriptor, settings, &block)
        scope = Scope.new(descriptor, settings)
        Docile.dsl_eval(scope, &block)

        scope.descriptor
      end

      private

      def _scope(new_settings = {}, &block)
        Scope.evaluate(descriptor, @settings.copy(new_settings), &block)
      end
    end
  end
end
