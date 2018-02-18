# frozen_string_literal: true

require 'modern/errors/web_errors'

require "modern/util/header_parsing"

module Modern
  class App
    module RequestHandling
      module OutputHandling
        private

        def determine_output_converter(request, route)
          accept_header = request.env["HTTP_ACCEPT"] || "*/*"

          requested_types =
            Modern::Util::HeaderParsing.parse_accept_header(accept_header) \
                                       .select { |c| route.content_types.any? { |ct| File.fnmatch(c, ct) } }

          ret =
            route.output_converters.find do |oc|
              requested_types.find do |c|
                File.fnmatch(c, oc.media_type)
              end
            end ||
            @descriptor.output_converters.find do |oc|
              requested_types.find do |c|
                File.fnmatch(c, oc.media_type)
              end
            end

          raise Errors::NotAcceptableError, "No servable types in Accept header: #{accept_header || 'nil'}" \
            if ret.nil?

          ret
        end

        def validate_output!(content, retval, request, route)
          if content.type.nil?
            retval
          else
            content.type[retval]
          end
        rescue Dry::Types::ConstraintError,
               Dry::Types::MissingKeyError,
               Dry::Struct::Error => err
          if @configuration.validate_responses != 'no'
            request.logger.error "Bad validation for response to #{route.id}, " \
                                "content type #{content.media_type}", err

            raise err if @configuration.validate_responses == 'error'
          end

          retval
        end
      end
    end
  end
end
