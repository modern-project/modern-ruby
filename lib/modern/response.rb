# frozen_string_literal: true

require 'rack'

require 'json'

module Modern
  class Response < Rack::Response
    attr_reader :request
    attr_reader :bypass

    def initialize(request, body = [], status = 200, header = {})
      super(body, status, header)

      @request = request
      @bypass = false
    end

    def bypass!
      @bypass = true
    end

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
