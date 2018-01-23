# frozen_string_literal: true

require "rack"

module Modern
  # `App` is the core of Modern. Some Rack application frameworks have you
  # inherit from them to generate your application; however, that makes it
  # pretty difficult to control immutability of the underlying routes. Since we
  # have a need to generate an OpenAPI specification off of our routes and
  # our behaviors, this is not an acceptable trade-off. As such, Modern expects
  # to be passed a 
  class App
  end
end
