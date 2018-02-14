# frozen_string_literal: true

require 'modern/dsl/info'
require 'modern/dsl/scope'

module Modern
  module DSL
    class Root < Scope
      DEFAULT_VALUE = Modern::Descriptor::Core.new(info: Info::DEFAULT_VALUE)

      attr_reader :descriptor

      def initialize(descriptor = DEFAULT_VALUE)
        @descriptor = descriptor
      end

      def info(&block)
        info = Info.build(&block)
        @descriptor = @descriptor.copy(info: info.to_h)
      end

      def input_converter(media_type_or_converter, &block)
        if media_type_or_converter.is_a?(Modern::Descriptor::Converters::Input::Base)
          @descriptor = @descriptor.copy(
            input_converters: @descriptor.input_converters + [media_type_or_converter]
          )
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
          @descriptor = @descriptor.copy(
            output_converters: @descriptor.output_converters + [media_type_or_converter]
          )
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

      def self.build(&block)
        Docile.dsl_eval(Root.new, &block).descriptor
      end
    end
  end
end
