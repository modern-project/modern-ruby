# frozen_string_literal: true

require "rack"

require "deep_dup"
require "ice_nine"

require "ougai"

require "modern/configuration"
require "modern/descriptor"
require "modern/services"

require "modern/request"
require "modern/response"

require "modern/app/error_handling"
require "modern/app/request_handling"
require "modern/app/trie_router"

require "modern/doc_generator/open_api3"

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
    attr_reader :services

    def initialize(descriptor, configuration = Modern::Configuration.new, services = Services.new)
      @descriptor = IceNine.deep_freeze(DeepDup.deep_dup(descriptor))
      @configuration = IceNine.deep_freeze(DeepDup.deep_dup(configuration))
      @services = services

      # TODO: figure out a good componentized naming scheme for Modern's own logs
      #       so as to clearly differentiate them from user logs.
      @logger = @services.base_logger

      @router = Modern::App::TrieRouter.new(
        routes: Modern::DocGenerator::OpenAPI3.new.decorate_with_openapi_routes(@configuration, @descriptor)
      )
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
        response.redirect(redirect.redirect_to, redirect.status)
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
