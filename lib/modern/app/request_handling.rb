# frozen_string_literal: true

require 'modern/errors/web_errors'

require 'modern/app/request_handling/request_container'
require 'modern/app/request_handling/input_handling'
require 'modern/app/request_handling/output_handling'

module Modern
  class App
    module RequestHandling
      include Modern::App::RequestHandling::InputHandling
      include Modern::App::RequestHandling::OutputHandling

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
          container = Modern::App::RequestHandling::RequestContainer.new(
            route_logger, route, request, response, params, body
          )

          retval = container.instance_eval(&route.action)

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

            retval = validate_output!(route_content, retval, request, route)

            response.headers["Content-Type"] = output_converter.media_type
            response.write(output_converter.converter.call(route_content.schema, retval))
          end
        rescue StandardError => err
          route_logger.error(err)
          raise
        end
      end
    end
  end
end
