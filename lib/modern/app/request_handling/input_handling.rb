# frozen_string_literal: true

require 'modern/errors/web_errors'

module Modern
  class App
    module RequestHandling
      module InputHandling
        private

        def parse_parameters(request, route)
          match = route.path_matcher.match(request.path)
          route_captures = match.names.map{ |n| [n.to_s, match[n]] }.to_h

          route.parameters.map { |p| [p.name, p.retrieve(request, route_captures)] }.to_h
        end

        def parse_request_body(request, route)
          input_converter = determine_input_converter(request, route)
          raise Modern::Errors::UnsupportedMediaTypeError if input_converter.nil?

          raw = input_converter.converter.call(request.body)

          t = route.request_body.type

          if raw.nil?
            nil
          elsif t.nil?
            raw
          else
            begin
              if raw.is_a?(Hash)
                raw = raw.map { |k, v| [k.respond_to?(:to_sym) ? k.to_sym : k, v] }.to_h
              end

              t[raw]
            rescue Dry::Types::ConstraintError,
                   Dry::Types::MissingKeyError,
                   Dry::Struct::Error => err
              request.logger.info("Struct parse error for route '#{route.id}'", err) \
                   if @configuration.log_input_converter_errors
              raise Modern::Errors::UnprocessableEntity, err.message
            rescue StandardError => err
              request.logger.warn("Unprocessable body for route '#{route.id}'", err) \
                if @configuration.log_input_converter_errors
              raise Modern::Errors::UnprocessableEntity
            end
          end
        end

        def determine_input_converter(request, route)
          # RFC 2616; you MAY sniff content but SHOULD return application/octet-stream
          # if the input Content-Type remains unknown. However, it seems like Rack may
          # default to application/x-www-form-urlencoded; Rack::Test definitely does.
          content_type = (request.content_type || "application/octet-stream").downcase.strip
          route.input_converters_by_type[content_type] || @input_converters[content_type]
        end
      end
    end
  end
end
