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

      def self.build(title, version, &block)
        d = Modern::Descriptor::Core.new(info: { title: title, version: version })
        Docile.dsl_eval(Root.new(d), &block).descriptor
      end
    end
  end
end
