require 'modern/app/flat_router'

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

  let(:get_subresource_deeper) do
    Modern::Descriptor::Route.new(
      id: "getSubResourceThing",
      http_method: :GET,
      path: "/sub-resource/{sub_resource_id}/thing",
      action: ->(a, b) {}
    )
  end

  let(:descriptor) do
    descriptor = Modern::Descriptor.new

    descriptor.add_route(get_root)
    descriptor.add_route(get_minimal)
    descriptor.add_route(get_subresource)
    descriptor.add_route(get_subresource_deeper)

    descriptor
  end

  let (:router) do
    Modern::App::FlatRouter.new(routes: descriptor.routes)
  end
end

describe Modern::App::FlatRouter do
  context "a few simple route paths" do
    include_context "routing test"

    it "instantiates" do
      router
    end

    it "404s on invalid routes" do
      Modern::Types::HTTP_METHODS.each do |m|
        expect(router.resolve(m, "/never-exists")).to be_nil
      end
    end

    it "can resolve a GET /" do
      expect(router.resolve(:GET, "/")).to eq(get_root)
    end

    it "can resolve a GET /minimal" do
      expect(router.resolve(:GET, "/minimal")).to eq(get_minimal)
    end

    it "can resolve a GET subresource with id" do
      expect(router.resolve(:GET, "/sub-resource/123")).to eq(get_subresource)
    end

    it "can resolve a GET subresource subpath" do
      expect(router.resolve(:GET, "/sub-resource/123/thing")).to eq(get_subresource_deeper)
    end
  end
end
