# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "modern/version"

Gem::Specification.new do |spec|
  spec.name                   = "modern"
  spec.version                = Modern::VERSION
  spec.required_ruby_version  = "~> 2.4"
  spec.authors                = ["Ed Ropple"]
  spec.email                  = ["ed@edropple.com"]

  spec.summary                = "The API-driven web framework for Ruby."
  spec.homepage               = "https://github.com/eropple/modern"
  spec.license                = "MIT"

  spec.files                  = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir                 = "exe"
  spec.executables            = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths          = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "rack-test", "~> 0.8"
  spec.add_development_dependency "rspec", "~> 3.7"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "rcodetools"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "ruby-debug-ide"

  spec.add_runtime_dependency "mime-types", "~> 3.1"
  spec.add_runtime_dependency "mime-types-data", "~> 3.2016"
  spec.add_runtime_dependency "rack", "~> 2.0"

  spec.add_runtime_dependency "http", "~> 3.0"

  spec.add_runtime_dependency "deep_dup", "~> 0.0.3"
  spec.add_runtime_dependency "diff-lcs", "~> 1.3"
  spec.add_runtime_dependency "dry-struct", "~> 0.4"
  spec.add_runtime_dependency "dry-validation", "~> 0.11"
  spec.add_runtime_dependency "snake_camel", "~> 1.1"
  spec.add_runtime_dependency "ice_nine", "~> 0.11.2"
end
