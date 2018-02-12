# frozen_string_literal: true

require 'modern/app'

require_relative './routes'

# TODO: test - ensure that route input converters override app input converters

describe Modern::Descriptor::RequestBody do
  include_context "request body routes"

  let(:descriptor) do
    Modern::Descriptor::Core.new(
      info: Modern::Descriptor::Info.new(
        title: "Request Body Spec",
        version: "1.0.0"
      ),
      routes: [
        required_body_hash_route,
        required_body_struct_route
      ],
      input_converters: [
        Modern::Descriptor::Converters::Input::JSON
      ],
      output_converters: [
        Modern::Descriptor::Converters::Output::JSON
      ]
    )
  end

  let(:app) do
    cfg = Modern::Configuration.new
    # dumping logs to a StringIO squelches them in rspec runs.
    Modern::App.new(descriptor, cfg, Modern::Services.new(base_logger: Ougai::Logger.new(StringIO.new)))
  end

  context "basic request body validation" do
    it "fails with a 415 if no input converter available" do
      header "Accept", "application/json" # output should never be hit
      header "Content-Type", "application/prs.never-available"
      post "/required-body-hash"

      expect(last_response.status).to eq(415)
    end

    it "fails with a 406 if no output converter available" do
      header "Accept", "application/prs.never-available"
      header "Content-Type", "application/json"
      post "/required-body-hash"

      expect(last_response.status).to eq(406)
    end

    it "fails with a 400 if a required request body is not provided" do
      header "Accept", "application/json"
      header "Content-Type", "application/json"
      post "/required-body-hash"

      expect(last_response.status).to eq(400)
    end

    context "hash schema" do
      it "fails with a 422 if the required request body is invalid" do
        header "Accept", "application/json"
        header "Content-Type", "application/json"
        post "/required-body-hash", {}.to_json

        expect(last_response.status).to eq(422)
      end

      it "follows the happy path" do
        header "Accept", "application/json"
        header "Content-Type", "application/json"
        post "/required-body-hash", { a: 5, b: "10" }.to_json

        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(JSON.parse(last_response.body)).to eq("a" => 5, "b" => 10)
        expect(last_response.status).to eq(200)
      end
    end

    context "struct" do
      it "fails with a 422 if the required request body is invalid" do
        header "Accept", "application/json"
        header "Content-Type", "application/json"
        post "/required-body-struct", {}.to_json

        expect(last_response.status).to eq(422)
      end

      it "follows the happy path" do
        header "Accept", "application/json"
        header "Content-Type", "application/json"
        post "/required-body-struct", { a: 5, b: "10" }.to_json

        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(JSON.parse(last_response.body)).to eq("a" => 5, "b" => 10)
        expect(last_response.status).to eq(200)
      end
    end
  end
end
