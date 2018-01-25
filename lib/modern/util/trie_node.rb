# frozen_string_literal: true

require "modern/errors/setup_errors"

module Modern
  module Util
    class TrieNode
      attr_reader :parent
      attr_reader :path
      attr_accessor :value

      attr_reader :children

      def initialize(path = [])
        @path = path
        @children = {}
      end

      def add(key, value, raise_if_present: false)
        key = [key].flatten

        if key.empty?
          if @value
            raise Modern::Errors::RoutingError, "Existing value at #{path.inspect}: #{@value}" \
              if raise_if_present
          end

          @value = value
        else
          child_name = key.first
          @children[child_name] ||= TrieNode.new(path + [child_name])

          @children[child_name].add(key[1..-1], value, raise_if_present: raise_if_present)
        end
      end

      def [](child_name)
        @children[child_name] || @children[:templated]
      end

      def get(key = [])
        key = [key].flatten

        node = self
        until key.empty? || node.nil?
          node = node[key.shift]
        end

        node&.value
      end
    end
  end
end
