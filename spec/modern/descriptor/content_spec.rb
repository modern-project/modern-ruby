# frozen_string_literal: true

require 'modern/app'

require_relative './routes'

# TODO: test - ensure that route output converters override app output converters

describe Modern::Descriptor::Content do
  include_context "content routes"

  let(:descriptor) do
    Modern::Descriptor::Core.new(
      info: Modern::Descriptor::Info.new(
        title: "Content Spec",
        version: "1.0.0"
      ),
      routes: [
        good_route_scalar,
        bad_route_scalar,
        good_route_hash,
        bad_route_hash,
        good_route_struct,
        bad_route_struct
      ],
      output_converters: [
        Modern::Descriptor::Converters::Output::JSON
      ]
    )
  end

  let(:app) do
    cfg = Modern::Configuration.new(
      validate_responses: "error"
    )
    # dumping logs to a StringIO squelches them in rspec runs.
    Modern::App.new(descriptor, cfg, Modern::Services.new(base_logger: Ougai::Logger.new(StringIO.new)))
  end

  context "basic validation" do
    context "scalar values" do
      it "validates when given good input" do
        header "Accept", "application/json"
        get "/good-route-scalar"

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq(5)
      end

      it "raises a 500 when given invalid input" do
        header "Accept", "application/json"
        get "/bad-route-scalar"

        expect(last_response.status).to eq(500)
      end
    end

    context "hashes" do
      it "validates when given good input" do
        header "Accept", "application/json"
        get "/good-route-hash"

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq("a" => "foo", "b" => 10)
      end

      it "raises a 500 when given invalid input" do
        header "Accept", "application/json"
        get "/bad-route-hash"

        expect(last_response.status).to eq(500)
      end
    end

    context "structs" do
      it "validates when given good input" do
        header "Accept", "application/json"
        get "/good-route-struct"

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)).to eq("a" => "foo", "b" => 10)
      end

      it "raises a 500 when given invalid input" do
        header "Accept", "application/json"
        get "/bad-route-struct"

        expect(last_response.status).to eq(500)
      end
    end
  end
end
