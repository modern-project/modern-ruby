# frozen_string_literal: true

require 'modern/descriptor'

module Example
  # TODO: implement routes into the example descriptor
  #       Modern was built specifically for a project I'm working on,
  #       so an end-to-end example is still TBD(eveloped). However,
  #       you can check out the tests for examples of how to write
  #       routes and security schemes; all internal objects are built
  #       with `dry-struct`
  # TODO: implement with modern-dsl when that's done (or maybe have a
  #       separate example for that?)
  def self.descriptor
    desc = Modern::Descriptor.new

    desc
  end
end
