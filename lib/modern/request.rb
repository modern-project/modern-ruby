# frozen_string_literal: true

require 'rack'
require 'securerandom'

module Modern
  class Request < Rack::Request
    # rubocop:disable Style/MutableConstant
    LOCAL_REQUEST_STORE = {}
    # rubocop:enable Style/MutableConstant

    attr_reader :logger

    def initialize(env, logger)
      super(env)

      env["HTTP_X_REQUEST_ID"] ||= SecureRandom.uuid

      @logger = logger.child(request_id: request_id)
    end

    def request_id
      env["HTTP_X_REQUEST_ID"]
    end

    def local_store
      LOCAL_REQUEST_STORE[request_id] ||= {}
    end

    def cleanup
      LOCAL_REQUEST_STORE.delete(request_id)
    end
  end
end
