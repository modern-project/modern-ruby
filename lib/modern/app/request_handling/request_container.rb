# frozen_string_literal: true

module Modern
  class App
    module RequestHandling
      # Encapsulates all non-derived portions of the request to run security
      # actions inside of it.
      class PartialRequestContainer
        attr_reader :logger
        attr_reader :configuration
        attr_reader :services
        attr_reader :route

        attr_reader :request
        attr_reader :response

        def initialize(logger, configuration, services, route, request, response)
          @logger = logger
          @configuration = configuration
          @services = services
          @route = route

          @request = request
          @response = response
        end

        def with_logger_fields(fields = {})
          original_logger = @logger
          @logger = original_logger.child(fields)

          ret = yield

          @logger = original_logger

          ret
        end
      end

      # Encapsulates all portions of the request, including params and body,
      # to have a route action run inside of it. This will be subclassed by
      # {Modern::Descriptor::Route}s that incorporate helper libraries.
      class FullRequestContainer < PartialRequestContainer
        attr_reader :params
        attr_reader :body

        def initialize(logger, configuration, services, route, request, response, params, body)
          super(logger, configuration, services, route, request, response)

          @params = params
          @body = body
        end
      end
    end
  end
end
