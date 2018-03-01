# frozen_string_literal: true

require 'modern/descriptor/info'

require 'docile'

module Modern
  module DSL
    class Info
      attr_reader :value

      def initialize(title, version)
        @value = Modern::Descriptor::Info.new(title: title, version: version)
      end

      def description(v)
        @value = @value.copy(description: v)
      end

      def terms_of_service(v)
        @value = @value.copy(terms_of_service: v)
      end

      def contact(name: nil, url: nil, email: nil)
        @value = @value.copy(contact: { name: name, url: url, email: email }.compact)
      end

      def license(name, url: nil)
        @value = @value.copy(license: { name: name, url: url }.compact)
      end

      def self.build(title, version, &block)
        i = Info.new(title, version)
        i.instance_exec(&block)
        i.value
      end
    end
  end
end
