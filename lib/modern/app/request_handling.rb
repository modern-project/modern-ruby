# frozen_string_literal: true

require 'content-type'

require 'modern/errors/web_errors'

module Modern
  class App
    module RequestHandling
      private

      # Encapsulates the full request handler for the app, given the route from
      # the router. `#take_request` then:
      #
      # - Performs parameter validation based on the parameters provided to the
      #   route's parameter spec, fills a parameters hash. If parameters do not
      #   validate, we raise a {Modern::Errors::BadRequestError}.
      # - Performs request body validation based on the request's `Content-Type`
      #   header against the request body type provided. If the request body
      #   does not validate, we raise a {Modern::Errors::BadRequestError}.
      # - Ensures that there is a {Modern::Descriptor::Response::Content} that
      #   can satisfy the requestor's `Accept` header. If no `Accept` header is
      #   given, then the first `Content` will be used; if no match is found
      #   between its `Accept` header and the `Content` objects for this route,
      #   we raise a {Modern::Errors::UnsupportedMediaTypeError}.
      def process_request(request, response, route)
        route_logger = request.logger.child(id: route.id)

        output_converter = determine_output_converter(request, route)
        raise Modern::Errors::NotAcceptableError \
          if output_converter.nil? || !route.content_types.include?(output_converter.media_type)

        params = parse_parameters(request, route)
        body = parse_request_body(request, route) unless route.request_body.nil?
        raise Modern::Errors::BadRequestError \
          if body.nil? && route.request_body&.required

        begin
          retval = route.action.call(request, response, params, body)

          # Leaving a hole for people to bypass responses and dump whatever
          # they want through the underlying `Rack::Response`.
          unless response.bypass
            route_code = route.responses_by_code.key?(response.status) ? response.status : :default

            route_response = route.responses_by_code[route_code]
            route_content = route_response.content_by_type[output_converter.media_type]

            if route_content.nil?
              raise Modern::Errors::InternalServiceError,
                    "no content for '#{output_converter.media_type}' for code #{route_code}"
            end

            validate_output!(route_content.schema, retval) unless route_content.schema.nil?

            response.headers["Content-Type"] = output_converter.media_type
            response.write(output_converter.converter.call(route_content.schema, retval))
          end
        rescue StandardError => err
          route_logger.error(err)
          raise
        end
      end

      def parse_parameters(request, route)
        match = route.path_matcher.match(request.path)
        route_captures = match.names.map{ |n| [n.to_s, match[n]] }.to_h

        route.parameters.map { |p| [p.name, p.retrieve(request, route_captures)] }.to_h
      end

      def parse_request_body(request, route)
        input_converter = determine_input_converter(request)
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
          rescue Dry::Types::ConstraintError => err
            raise Modern::Errors::UnprocessableEntity, err.message
          rescue Dry::Types::MissingKeyError => err
            raise Modern::Errors::UnprocessableEntity, err.message
          rescue StandardError => err
            request.logger.warn "Unprocessable body for route '#{route.id}'", err
            raise Modern::Errors::UnprocessableEntity
          end
        end
      end

      def determine_input_converter(request)
        # RFC 2616; you MAY sniff content but SHOULD return application/octet-stream
        # if the input Content-Type remains unknown. However, it seems like Rack may
        # default to application/x-www-form-urlencoded; Rack::Test definitely does.
        content_type = request.content_type.downcase.strip
        @input_converters[content_type]
      end

      def determine_output_converter(request, route)
        accept_header = request.env["HTTP_ACCEPT"]
        requested_types = Modern::Util::HeaderParsing.parse_accept_header(accept_header) \
          .select { |c| route.content_types.include?(c) }

        @output_converters[requested_types.find { |c| @output_converters.key?(c) }]
      end

      def validate_output!(_schema, _retval)
        nil
      end
    end
  end
end
