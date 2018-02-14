# frozen_string_literal: true

require 'modern/descriptor/info'

require 'docile'

module Modern
  module DSL
    class Info
      DEFAULT_VALUE = Modern::Descriptor::Info.new(title: "UNNAMED MODERN API", version: "1.0.0")

      attr_reader :value

      def initialize(value = DEFAULT_VALUE)
        @value = value
      end

      def title(v)
        @value = @value.copy(title: v)
      end

      def description(v)
        @value = @value.copy(description: v)
      end

      def terms_of_service(v)
        @value = @value.copy(terms_of_service: v)
      end

      def version(v)
        @value = @value.copy(version: v)
      end

      def contact(name: nil, url: nil, email: nil)
        @value = @value.deep_copy(contact: { name: name, url: url, email: email }.compact)
      end

      def license(name, url: nil)
        @value = @value.deep_copy(license: { name: name, url: url }.compact)
      end

      def self.build(&block)
        Docile.dsl_eval(Info.new, &block).value
      end
    end
  end
end
