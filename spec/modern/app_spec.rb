# frozen_string_literal: true

require 'modern/app'
require 'modern/doc_generator/open_api3'

describe Modern::App do
  context "an App with an empty Descriptor" do
    let(:descriptor) do
      Modern::Descriptor::Core.new(
        info: Modern::Descriptor::Info.new(
          title: "App Spec",
          version: "1.0.0"
        ),
        routes: []
      )
    end

    let(:app) do
      Modern::App.new(descriptor)
    end

    it "404s when hitting / with no route" do
      header "Accept", "application/json"
      get "/"

      # we attach the request id to errors, so we have to dig for the error.
      expect(JSON.parse(last_response.body).dig("message")).to eq("Not found")
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(last_response.status).to eq(404)
    end

    it "returns an X-Response-Id header with its responses" do
      header "Accept", "application/json"
      get "/"

      id1 = last_response.headers["X-Request-Id"]

      header "Accept", "application/json"
      get "/"

      id2 = last_response.headers["X-Request-Id"]

      expect(id1).not_to be_nil
      expect(id2).not_to be_nil
      expect(id1).not_to eq(id2)
    end

    it "serves a valid OpenAPI3 JSON document at the expected path" do
      get "/openapi.json"

      expect(last_response.status).to eq(200)

      body = JSON.parse(last_response.body)
      expect(body.dig("openapi")).to eq(Modern::DocGenerator::OpenAPI3::OPENAPI_VERSION)
      expect(body.dig("info", "title")).to eq("App Spec")

      doc = Openapi3Parser.load(body)

      expect(doc.errors.to_a).to eq([])
    end

    it "serves a valid OpenAPI3 YAML document at the expected path" do
      get "/openapi.yaml"

      expect(last_response.status).to eq(200)

      body = YAML.safe_load(last_response.body)
      expect(body.dig("openapi")).to eq(Modern::DocGenerator::OpenAPI3::OPENAPI_VERSION)
      expect(body.dig("info", "title")).to eq("App Spec")

      doc = Openapi3Parser.load(body)

      expect(doc.errors.to_a).to eq([])
    end
  end
end
