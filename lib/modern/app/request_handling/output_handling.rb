# frozen_string_literal: true

require 'modern/errors/web_errors'

module Modern
  class App
    module RequestHandling
      module OutputHandling
        private

        def determine_output_converter(request, route)
          # TODO: handle the wildcard case.
          accept_header = request.env["HTTP_ACCEPT"] || "*/*"
          requested_types =
            Modern::Util::HeaderParsing.parse_accept_header(accept_header) \
                                       .select { |c| route.content_types.include?(c) }

          @output_converters[requested_types.find { |c| @output_converters.key?(c) }]
        end
      end
    end
  end
end
