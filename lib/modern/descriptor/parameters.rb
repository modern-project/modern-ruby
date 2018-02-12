# frozen_string_literal: true

require "modern/struct"
require "modern/errors/web_errors"

module Modern
  module Descriptor
    module Parameters
      class Base < Modern::Struct
        # TODO: maybe do something behind-the-scenes where `required` is
        #       expressed as part of dry-types (| Types::Nil); we need
        #       the field for easily generating a doc later, but we could parse
        #       it out of the type if we had to.
        Type = Types.Instance(self)

        attribute :name, Types::Strict::String
        attribute :type, Types::Type
        attribute :description, Types::Strict::String.optional.default(nil)
        attribute :deprecated, Types::Strict::Bool.default(false)

        def friendly_name
          name
        end

        def retrieve(request, route_captures)
          ret = do_retrieve(request, route_captures)

          raise Errors::BadRequestError, "Invalid/missing parameter '#{friendly_name}'." \
            if required && ret.nil?

          begin
            ret.nil? ? nil : type[ret]
          rescue StandardError => _err
            raise Errors::InternalServiceError,
                  "Couldn't interpret the value provided for parameter '#{friendly_name}': #{ret}."
          end
        end

        def openapi3_in
          self.class.name.split("::").last.downcase
        end

        def do_retrieve(_request, _route_captures)
          raise "#{self.class.name}#do_retrieve(request, route_captures) must be implemented."
        end

        def to_openapi3(is_api_key = false)
          {
            name: friendly_name,
            in: openapi3_in,
            required: !is_api_key ? required : nil,
            description: !is_api_key ? description : nil,
            deprecated: !is_api_key ? deprecated : nil
          }.compact
        end
      end

      class Path < Base
        Type = Types.Instance(self)

        # TODO: add 'matrix' and 'label'
        attribute :style, Types::Coercible::String.default("simple").enum("simple")

        def required
          true
        end

        def do_retrieve(_request, route_captures)
          route_captures[name]
        end
      end

      class Cookie < Base
        Type = Types.Instance(self)

        attribute :cookie_name, Types::Coercible::String
        attribute :style, Types::Coercible::String.default("form").enum("form")
        attribute :required, Types::Strict::Bool.default(false)

        def friendly_name
          cookie_name
        end

        def do_retrieve(request, _route_captures = nil)
          request.cookies[cookie_name]
        end
      end

      class Header < Base
        Type = Types.Instance(self)

        attribute :header_name, Types::Coercible::String
        attribute :style, Types::Coercible::String.default("simple").enum("simple")
        attribute :required, Types::Strict::Bool.default(false)

        attr_reader :rack_env_key

        def initialize(fields)
          super(fields)

          @rack_env_key = "HTTP_" + header_name.upcase.tr("-", "_")
        end

        def friendly_name
          header_name
        end

        def do_retrieve(request, _route_captures = nil)
          request.env[@rack_env_key]
        end
      end

      class Query < Base
        Type = Types.Instance(self)

        # TODO: add 'space_delimited', 'pipe_delimited', 'deep_object'
        attribute :style, Types::Coercible::String.default("form").enum("form")
        attribute :required, Types::Strict::Bool.default(false)

        attribute :allow_empty_value, Types::Strict::Bool.default(false)
        attribute :allow_reserved, Types::Strict::Bool.default(false)

        attr_reader :parser

        def initialize(fields)
          super(fields)

          @query_parser = Rack::QueryParser.make_default(99, 99)
        end

        def do_retrieve(request, _route_captures = nil)
          @query_parser.parse_query(request.query_string)[name]
        end

        def to_openapi3(is_api_key = false)
          super.merge(
            allowEmptyValue: !is_api_key ? description : nil,
            allowReserved: !is_api_key ? allow_reserved : nil
          ).compact
        end
      end
    end
  end
end
