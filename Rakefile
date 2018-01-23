# frozen_string_literal: true

require "bundler/gem_tasks"
task default: :spec

task spec: [] do
  Dir.chdir __dir__ do
    sh "rspec --require spec_helper spec/**/*.rb"
  end
end
