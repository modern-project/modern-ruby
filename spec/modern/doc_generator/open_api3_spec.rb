# frozen_string_literal: true

require 'openapi3_parser'

require 'modern/descriptor'
require 'modern/doc_generator/open_api3'

require_relative '../descriptor/routes'

shared_context "openapi3 infos" do
  let(:minimal_info) do
    Modern::Descriptor::Info.new(
      title: "Minimal Info",
      version: "1.0.0"
    )
  end

  let(:full_info) do
    Modern::Descriptor::Info.new(
      title: "Full Info",
      version: "1.0.0",
      description: "this is an info",
      contact: Modern::Descriptor::Info::Contact.new(
        name: "Ed Ropple",
        url: "https://edboxes.com",
        email: "ed+modern@edropple.com"
      ),
      license: Modern::Descriptor::Info::License.new(
        name: "MIT",
        url: "https://opensource.org/licenses/MIT"
      )
    )
  end
end

describe Modern::DocGenerator::OpenAPI3 do
  include_context "parameter routes"
  include_context "security routes"
  include_context "request body routes"
  include_context "content routes"

  let(:descriptor) do
    Modern::Descriptor::Core.new(
      info: Modern::Descriptor::Info.new(
        title: "Full Descriptor",
        version: "1.0.0"
      ),
      routes: [
        path_route,
        http_bearer,
        http_multi,
        apikey_header,
        required_body_hash_route,
        required_body_struct_route,
        required_nested_struct_route,
        good_route_scalar,
        good_route_hash,
        good_route_struct
      ]
    )
  end

  let(:generator) do
    Modern::DocGenerator::OpenAPI3.new
  end

  context "OAPI3 info objects" do
    include_context "openapi3 infos"

    it "handles the minimal case" do
      info = generator._info(minimal_info)

      expect(info).to eq(title: "Minimal Info", version: "1.0.0")
    end

    it "handles the full case" do
      info = generator._info(full_info)

      expect(info[:title]).to eq("Full Info")
      expect(info[:contact][:name]).to eq("Ed Ropple")
      expect(info[:license][:name]).to eq("MIT")
    end
  end

  context "full generator" do
    it "successfully generates a valid document from a descriptor" do
      hash = generator.hash(descriptor)
      json = JSON.pretty_generate(hash)
      yaml = YAML.dump(JSON.parse(json))
      doc = Openapi3Parser.load(yaml)

      expect(doc.errors.errors).to eq([])
    end
  end
end
