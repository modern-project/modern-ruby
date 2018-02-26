# frozen_string_literal: true

require 'modern/capsule'
require 'modern/descriptor'
require 'modern/dsl'

unless Object.constants.include?(:DSLFixtures)
  module DSLFixtures
    TestCapsule =
      Modern::Capsule.define do
        get :testCapsuleRoute do; end
      end
  end
end

describe Modern::DSL do
  it "builds a correct Info" do
    ret =
      Modern::Descriptor.define("Info Test", "1.0.5") do
        info do
          license "MIT", url: "https://opensource.org/licenses/MIT"
        end
      end

    expect(ret.info.title).to eq("Info Test")
    expect(ret.info.version).to eq("1.0.5")
    expect(ret.info.license.url).to eq("https://opensource.org/licenses/MIT")
  end

  it "includes a capsule in a separate scope" do
    ret =
      Modern::Descriptor.define("Capsule", "1.0.0") do
        capsule DSLFixtures::TestCapsule
      end

    expect(ret.routes.first.id).to eq("testCapsuleRoute")
  end

  it "supports routes with all standard verbs" do
    ret = Modern::Descriptor.define("Simple Route", "1.0.0") do
      get :testRouteGet do; end
      post :testRoutePost do; end
      put :testRoutePut do; end
      delete :testRouteDelete do; end
      patch :testRoutePatch do; end
    end

    expect(ret.routes[0].id).to eq("testRouteGet")
    expect(ret.routes[1].id).to eq("testRoutePost")
    expect(ret.routes[2].id).to eq("testRoutePut")
    expect(ret.routes[3].id).to eq("testRouteDelete")
    expect(ret.routes[4].id).to eq("testRoutePatch")
  end

  it "namespaces by path and allows extending routes with their own paths" do
    ret = Modern::Descriptor.define("Simple Route", "1.0.0") do
      get :baseRoute do; end
      get :ownPathRoute, "my-own-route" do; end

      path "sub-path" do
        get :subPathBaseRoute do; end
        get :subPathOwnPathRoute, "my-own-route" do; end
      end
    end

    expect(ret.routes_by_id["baseRoute"].path).to eq("/")
    expect(ret.routes_by_id["ownPathRoute"].path).to eq("/my-own-route")
    expect(ret.routes_by_id["subPathBaseRoute"].path).to eq("/sub-path")
    expect(ret.routes_by_id["subPathOwnPathRoute"].path).to eq("/sub-path/my-own-route")
  end
end
