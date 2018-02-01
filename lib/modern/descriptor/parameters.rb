# frozen_string_literal: true

require "modern/struct"
require "modern/errors/web_errors"

module Modern
  module Descriptor
    module Parameters
      class Base < Modern::Struct
        # TODO: maybe do something behind-the-scenes where `required` is
        #       expressed as part of dry-types (| Modern::Types::Nil); we need
        #       the field for easily generating a doc later, but we could parse
        #       it out of the type if we had to.
        Type = Modern::Types.Instance(self)

        attribute :name, Modern::Types::Strict::String
        attribute :type, Modern::Types::Type
        attribute :description, Modern::Types::Strict::String.optional.default(nil)
        attribute :required, Modern::Types::Strict::Bool.default(false)
        attribute :deprecated, Modern::Types::Strict::Bool.default(false)

        def friendly_name
          name
        end

        def retrieve(request)
          ret = do_retrieve(request)

          raise Modern::Errors::BadRequestError, "Invalid/missing parameter '#{friendly_name}'." \
            if required && ret.nil?

          begin
            ret.nil? ? nil : type[ret]
          rescue
            raise "Couldn't interpret the value provided for parameter '#{friendly_name}': #{ret}."
          end
        end

        private

        def do_retrieve(_request)
          raise "#{self.class.name}#do_retrieve(request) must be implemented."
        end
      end

      class Path < Base
        Type = Modern::Types.Instance(self)

        attribute :style, Modern::Types::Coercible::String.default("simple").enum("matrix", "label", "simple")
      end

      class Cookie < Base
        Type = Modern::Types.Instance(self)

        attribute :style, Modern::Types::Coercible::String.default("form").enum("form")
      end

      class Header < Base
        Type = Modern::Types.Instance(self)

        attribute :header_name, Modern::Types::Coercible::String
        attribute :style, Modern::Types::Coercible::String.default("simple").enum("simple")

        attr_reader :rack_env_key

        def initialize(fields)
          super(fields)

          @rack_env_key = "HTTP_" + header_name.upcase.tr("-", "_")
        end

        def friendly_name
          header_name
        end

        private

        def do_retrieve(request)
          request.env[@rack_env_key]
        end
      end

      class Query < Base
        Type = Modern::Types.Instance(self)

        attribute :style, Modern::Types::Coercible::String.default("form").enum("form", "space_delimited", "pipe_delimited", "deep_object")

        attribute :allow_empty_value, Modern::Types::Strict::Bool.default(false)
        attribute :allow_reserved, Modern::Types::Strict::Bool.default(false)

        attr_reader :parser

        def initialize(fields)
          super(fields)

          @query_parser = Rack::QueryParser.make_default(99, 99)
        end

        private

        def do_retrieve(request)
          @query_parser.parse_query(request.query_string)[name]
        end
      end
    end
  end
end
