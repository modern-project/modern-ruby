# frozen_string_literal: true

require 'diff/lcs'

require_relative './router'

require 'modern/util/trie_node'

module Modern
  class App
    class TrieRouter < Router
      def initialize(inputs)
        super(inputs)

        @trie = build_trie(routes)
      end

      def resolve(http_method, path)
        trie_path = path.sub(%r|^/|, "").split("/") + [http_method.to_s.upcase]
        @trie.get(trie_path)
      end

      private

      def build_trie(routes)
        trie = Modern::Util::TrieNode.new
        routes.each do |route|
          route.path_matcher # pre-seed the path matcher

          trie.add(route.route_tokens + [route.http_method], route, raise_if_present: true)
        end

        trie
      end
    end
  end
end
