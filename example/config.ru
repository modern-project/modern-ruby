# frozen_string_literal: true

require 'rack/ougai'

require 'modern/app'
require_relative './example'

use Rack::Ougai::Logger, Logger::INFO
use Rack::Ougai::LogRequests

run Modern::App.new(Example.descriptor)
