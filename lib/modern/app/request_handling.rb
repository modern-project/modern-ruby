# frozen_string_literal: true

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

        params = parse_parameters(request, route)
        body = parse_request_body(request, route)

        begin
          route.action.call(request, response, params, body)
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
        if route.request_body.nil?
          nil
        else
          nil
        end
      end

      def validate_for_content_response(request, response, route)
        # TODO: validate Accept versus response types

        accept_header = request.env["HTTP_ACCEPT"]
        requested_types = Modern::Util::HeaderParsing.parse_accept_header(accept_header)
      end
    end
  end
end
