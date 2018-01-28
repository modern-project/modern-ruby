# frozen_string_literal: true

module Modern
  class App
    module ErrorHandling
      private

      def handle_error(response, err)
        ret = {}

        is_internal_error = err.is_a?(Modern::Errors::WebError)

        ret[:message] =
          if is_internal_error
            err.message
          else
            @configuration.show_errors ? err.message : "An error occurred."
          end

        if !is_internal_error && @configuration.show_errors
          ret[:backtrace] = err.backtrace
        end

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
