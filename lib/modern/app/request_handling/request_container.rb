# frozen_string_literal: true

module Modern
  class App
    module RequestHandling
      # Provides a convenient context in which to run a single request.
      class RequestContainer
        attr_reader :logger
        attr_reader :route

        attr_reader :request
        attr_reader :response

        attr_reader :params
        attr_reader :body

        def initialize(logger, route, request, response, params, body)
          @logger = logger
          @route = route

          @request = request
          @response = response

          @params = params
          @body = body

          # TODO: There's probably a nontrivial performance impact to this.
          #       Maybe we create a RequestContainer subclass for every route?
          #       That also seems bad...
          route.helpers.each { |h| extend h }
        end
      end
    end
  end
end
