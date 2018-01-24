# frozen_string_literal: true

require "rack"

require "deep_dup"
require "ice_nine"

require "modern/configuration"
require "modern/descriptor"

require "modern/request"
require "modern/response"

require "modern/app/error_handling"
require "modern/app/router"

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

    def initialize(descriptor, configuration = Modern::Configuration.new)
      @descriptor = IceNine.deep_freeze(DeepDup.deep_dup(descriptor))
      @configuration = IceNine.deep_freeze(DeepDup.deep_dup(configuration))

      @router = Modern::App::Router.new(routes: @descriptor.routes)
    end

    def call(env)
      request = Modern::Request.new(env)
      response = Modern::Response.new
      route = @router.resolve(request.request_method, request.path_info)

      begin
        raise Modern::Errors::NotFoundError if route.nil?

        response.finish
      rescue Modern::Redirect => redirect
        response.redirect(redirect.target, redirect.status)
      rescue StandardError => err
        handle_error(response, err)
        response.finish
      end
    end
  end
end
