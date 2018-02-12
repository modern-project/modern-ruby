# frozen_string_literal: true

require 'modern/errors/web_errors'

require "modern/util/header_parsing"

module Modern
  class App
    module RequestHandling
      module OutputHandling
        private

        def determine_output_converter(request, route)
          # TODO: handle the wildcard case.
          accept_header = request.env["HTTP_ACCEPT"] || "*/*"
          requested_types =
            Modern::Util::HeaderParsing.parse_accept_header(accept_header) \
                                       .select { |c| route.content_types.include?(c) }

          route.output_converters_by_type[requested_types.find do |c|
            route.output_converters_by_type.key?(c)
          end] ||
            @output_converters[requested_types.find do |c|
              @output_converters.key?(c)
            end]
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
