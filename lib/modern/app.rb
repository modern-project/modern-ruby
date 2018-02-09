# frozen_string_literal: true

require "rack"

require "deep_dup"
require "ice_nine"

require "ougai"

require "modern/configuration"
require "modern/descriptor"

require "modern/request"
require "modern/response"

require "modern/app/error_handling"
require "modern/app/request_handling"
require "modern/app/trie_router"

require "modern/errors"
require "modern/redirect"

module Modern
  # `App` is the core of Modern. Some Rack application frameworks have you
  # inherit from them to generate your application; however, that makes it
  # pretty difficult to control immutability of the underlying routes. Since we
  # have a need to generate an OpenAPI specification off of our routes and
  # our behaviors, this is not an acceptable trade-off. As such, Modern expects
  # to be passed a {Modern::Description::Descriptor}, which specifies a set of
  # {Modern::Description::Route}s. The app then dispatches requests based on
  # these routes.
  class App
    include Modern::App::ErrorHandling
    include Modern::App::RequestHandling

    attr_reader :logger

    def initialize(descriptor, configuration = Modern::Configuration.new, logger = Ougai::Logger.new($stderr))
      @descriptor = IceNine.deep_freeze(DeepDup.deep_dup(descriptor))
      @configuration = IceNine.deep_freeze(DeepDup.deep_dup(configuration))

      @logger = logger

      @router = Modern::App::TrieRouter.new(routes: @descriptor.routes)
      @input_converters = @descriptor.input_converters.map { |c| [c.media_type.downcase.strip, c] }.to_h
      @output_converters = @descriptor.output_converters.map { |c| [c.media_type.downcase.strip, c] }.to_h
    end

    def call(env)
      request = Modern::Request.new(env, logger)
      response = Modern::Response.new(request)
      response.headers["X-Request-Id"] = request.request_id

      route = @router.resolve(request.request_method, request.path_info)

      begin
        raise Modern::Errors::NotFoundError if route.nil?

        process_request(request, response, route)
        response.finish
      rescue Modern::Redirect => redirect
        response.redirect(redirect.target, redirect.status)
      rescue Modern::Errors::WebError => err
        catch_web_error(response, err)
      rescue StandardError => err
        catch_unhandled_error(response, err)
      ensure
        response.finish
        request.cleanup
      end

      response.to_a
    end
  end
end
