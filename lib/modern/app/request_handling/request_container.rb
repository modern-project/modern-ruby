# frozen_string_literal: true

module Modern
  class App
    module RequestHandling
      # Encapsulates all non-derived portions of the request to run security
      # actions inside of it.
      class PartialRequestContainer
        attr_reader :logger
        attr_reader :services
        attr_reader :route

        attr_reader :request
        attr_reader :response

        def initialize(logger, services, route, request, response)
          @logger = logger
          @services = services
          @route = route

          @request = request
          @response = response
        end

        def to_full(params, body)
          FullRequestContainer.new(logger, services, route, request, response, params, body)
        end
      end

      # Encapsulates all portions of the request, including params and body,
      # to have a route action run inside of it.
      class FullRequestContainer < PartialRequestContainer
        attr_reader :params
        attr_reader :body

        def initialize(logger, services, route, request, response, params, body)
          super(logger, services, route, request, response)

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
