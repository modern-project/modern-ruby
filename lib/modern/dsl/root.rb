# frozen_string_literal: true

require 'modern/dsl/info'
require 'modern/dsl/scope'

module Modern
  module DSL
    class Root < Scope
      attr_reader :descriptor

      def initialize(descriptor)
        super(descriptor, nil)
      end

      def info(&block)
        @descriptor = @descriptor.copy(
          info: Info.build(descriptor.info.title, descriptor.info.version, &block).to_h
        )
      end

      def server(url, description: nil)
        raise "url is required for a server declaration." if url.nil?

        @descriptor = @descriptor.copy(
          servers: @descriptor.servers + [Modern::Descriptor::Server.new(url: url, description: description)]
        )
      end

      # def input_converter(media_type_or_converter, &block)
      #   if media_type_or_converter.is_a?(Modern::Descriptor::Converters::Input::Base)
      #     @descriptor = @descriptor.copy(
      #       input_converters: @descriptor.input_converters + [media_type_or_converter]
      #     )
      #   elsif media_type_or_converter.is_a?(String) && !block.nil?
      #     input_converter(
      #       Modern::Descriptor::Converters::Input::Base.new(
      #         media_type: media_type_or_converter, converter: block
      #       )
      #     )
      #   else
      #     raise "must pass a String and block or a Modern::Descriptor::Converters::Input::Base."
      #   end
      # end

      # def output_converter(media_type_or_converter, &block)
      #   if media_type_or_converter.is_a?(Modern::Descriptor::Converters::Output::Base)
      #     @descriptor = @descriptor.copy(
      #       output_converters: @descriptor.output_converters + [media_type_or_converter]
      #     )
      #   elsif media_type_or_converter.is_a?(String) && !block.nil?
      #     output_converter(
      #       Modern::Descriptor::Converters::Output::Base.new(
      #         media_type: media_type_or_converter, converter: block
      #       )
      #     )
      #   else
      #     raise "must pass a String and block or a Modern::Descriptor::Converters::Output::Base."
      #   end
      # end

      def self.build(title, version, &block)
        d = Modern::Descriptor::Core.new(info: { title: title, version: version })
        Docile.dsl_eval(Root.new(d), &block).descriptor
      end
    end
  end
end
