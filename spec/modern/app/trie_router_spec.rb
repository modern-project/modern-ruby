require 'modern/app/trie_router'

shared_context "routing test" do
  let(:get_root) do
    Modern::Descriptor::Route.new(
      id: "getRoot",
      http_method: :GET,
      path: "/",
      summary: "The root of the app.",
      tags: [:meta],
      action: ->(a, b) {}
    )
  end

  let(:get_minimal) do
    Modern::Descriptor::Route.new(
      id: "getMinimal",
      http_method: :GET,
      path: "/minimal",
      action: ->(a, b) {}
    )
  end

  let(:get_subresource) do
    Modern::Descriptor::Route.new(
      id: "getSubResource",
      http_method: :GET,
      path: "/sub-resource/{sub_resource_id}",
      action: ->(a, b) {}
    )
  end

  let(:get_subresource_override) do
    Modern::Descriptor::Route.new(
      id: "getSubResource",
      http_method: :GET,
      path: "/sub-resource/special",
      action: ->(a, b) {}
    )
  end

  let(:get_subresource_deeper) do
    Modern::Descriptor::Route.new(
      id: "getSubResourceThing",
      http_method: :GET,
      path: "/sub-resource/{sub_resource_id}/thing",
      action: ->(a, b) {}
    )
  end

  let(:get_subresource_deeper2) do
    Modern::Descriptor::Route.new(
      id: "getSubResourceThing",
      http_method: :GET,
      path: "/sub-resource/{not_a_sub_resource_id}/thing",
      action: ->(a, b) {}
    )
  end

  let(:descriptor) do
    descriptor = Modern::Descriptor.new

    descriptor.add_route(get_root)
    descriptor.add_route(get_minimal)
    descriptor.add_route(get_subresource)
    descriptor.add_route(get_subresource_override)
    descriptor.add_route(get_subresource_deeper)

    descriptor
  end

  let :dupe_descriptor do
    descriptor = Modern::Descriptor.new

    descriptor.add_route(get_subresource_deeper)
    descriptor.add_route(get_subresource_deeper2)

    descriptor
  end

  let (:router) do
    Modern::App::TrieRouter.new(routes: descriptor.routes)
  end

  let (:dupe_router) do
    Modern::App::TrieRouter.new(routes: dupe_descriptor.routes)
  end
end

describe Modern::App::TrieRouter do
  context "a few simple route paths" do
    include_context "routing test"

    it "rejects multiple routes on the same path" do
      expect { dupe_router }.to raise_error(Modern::Errors::RoutingError)
    end
    it "instantiates" do
      router
    end


    it "404s on invalid routes" do
      Modern::Types::HTTP_METHODS.each do |m|
        expect(router.resolve(m, "/never-exists")).to be_nil
      end
    end

    it "can resolve a concrete root" do
      expect(router.resolve(:GET, "/")).to eq(get_root)
    end

    it "can resolve a concrete path" do
      expect(router.resolve(:GET, "/minimal")).to eq(get_minimal)
    end

    it "prioritizes concrete paths over templated paths" do
      expect(router.resolve(:GET, "/sub-resource/special")).to eq(get_subresource_override)
    end

    it "can resolve a template" do
      expect(router.resolve(:GET, "/sub-resource/123")).to eq(get_subresource)
    end

    it "won't fall down a template subpath if a concrete path exists" do
      expect(router.resolve(:GET, "/sub-resource/special/thing")).to be_nil
    end

    it "can resolve a template subpath" do
      expect(router.resolve(:GET, "/sub-resource/123/thing")).to eq(get_subresource_deeper)
    end
  end
end
