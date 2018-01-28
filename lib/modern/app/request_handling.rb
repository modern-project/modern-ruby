# frozen_string_literal: true

module Modern
  class App
    module ErrorHandling
      private

      # Encapsulates the full request handler for the app, given the route from the
      # router. `#take_request` then:
      #
      # - Ensures that there is a {Modern::Descriptor::Response::Content} that can
      #   satisfy the requestor's `Accept` header. If no `Accept` header is given,
      #   then the first `Content` will be used; if no match is found between its
      #   `Accept` header and the `Content` objects for this route, we raise a
      #   {Modern::Errors::UnsupportedMediaTypeError}.
      # - Performs parameter validation based on
      def take_request(request, response, route)
      end
    end
  end
end
