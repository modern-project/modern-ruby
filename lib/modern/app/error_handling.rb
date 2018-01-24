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

        response.status = err.respond_to?(:status) ? err.status : 500;
        response.json(ret)
      end
    end
  end
end
