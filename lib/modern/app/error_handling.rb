# frozen_string_literal: true

module Modern
  class App
    module ErrorHandling
      private

      def catch_web_error(response, err)
        ret = {
          message: err.message,
          request_id: response.headers["X-Request-Id"]
        }

        # TODO: We maybe shouldn't hard-code a default to a JSON retval from a
        # 404. On the other hand...maybe we should. Knowledgeable clients
        # shouldn't be parsing a 404 unless the 404 is specified in a route's
        # responses, and so this could just be garbage data except during
        # development/debugging.
        response.status = err.status;
        response.json(ret)
      end

      def catch_unhandled_error(response, err)
        ret = {
          message: @configuration.show_errors ? err.message : "An error occurred.",
          request_id: response.headers["X-Request-Id"]
        }

        if @configuration.show_errors
          ret[:backtrace] = err.backtrace
        end

        logger.error "Unhandled exception caught by main loop.", err

        # TODO: We maybe shouldn't hard-code a default to a JSON retval from a
        # 404. On the other hand...maybe we should. Knowledgeable clients
        # shouldn't be parsing a 404 unless the 404 is specified in a route's
        # responses, and so this could just be garbage data except during
        # development/debugging.
        response.status = err.respond_to?(:status) ? err.status : 500;
        response.json(ret)
      end
    end
  end
end
