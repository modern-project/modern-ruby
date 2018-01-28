# frozen_string_literal: true

require 'rack'

require 'json'

module Modern
  class Response < Rack::Response
    def json(object, pretty: false)
      headers["Content-Type"] = "application/json"

      if pretty
        write(JSON.pretty_generate(object))
      else
        write(JSON.generate(object))
      end
    end

    def text(object)
      headers["Content-Type"] = "text/plain"

      write(object.to_s)
    end
  end
end
