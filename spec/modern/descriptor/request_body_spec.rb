# frozen_string_literal: true

require 'modern/app'

shared_context "request body test" do
  let(:required_body_route) do
    Modern::Descriptor::Route.new(
      id: "postRequiredBody",
      http_method: :POST,
      path: "/required-body",
      summary: "when the request body is required",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json"
            )
          ]
        )
      ],
      request_body:
        Modern::Descriptor::RequestBody.new(
          type: Modern::Types::Strict::Hash.strict_with_defaults(
            a: Modern::Types::Strict::Int,
            b: Modern::Types::Coercible::Int,
            c: Modern::Types::Strict::Int.optional.default(nil)
          ),
          required: true
        ),
      action:
        proc do |_req, res, _params, body|
          res.json(body)
        end
    )
  end

  let(:descriptor) do
    Modern::Descriptor::Core.new(
      info: Modern::OpenAPI3::Info.new(
        title: "Request Body Spec",
        version: "1.0.0"
      ),
      routes: [
        required_body_route
      ],
      security_schemes: [],
      input_converters: [
        Modern::Descriptor::Converters::Input::JSON
      ],
      output_converters: [
        Modern::Descriptor::Converters::Output::JSON
      ]
    )
  end

  let(:app) do
    Modern::App.new(descriptor)
  end
end

describe Modern::Descriptor::RequestBody do
  context "basic request body validation" do
    include_context "request body test"

    it "fails with a 415 if no input converter available" do
      header "Accept", "application/json" # output should never be hit
      header "Content-Type", "application/prs.never-available"
      post "/required-body"

      expect(last_response.status).to eq(415)
    end

    it "fails with a 406 if no output converter available" do
      header "Accept", "application/prs.never-available"
      header "Content-Type", "application/json"
      post "/required-body"

      expect(last_response.status).to eq(406)
    end

    it "fails with a 400 if a required request body is not provided" do
      header "Accept", "application/json"
      header "Content-Type", "application/json"
      post "/required-body"

      expect(last_response.status).to eq(400)
    end

    it "fails with a 422 if the required request body is not of the right schema" do
      header "Accept", "application/json"
      header "Content-Type", "application/json"
      post "/required-body", {}.to_json

      expect(last_response.status).to eq(422)
    end

    it "follows the request happy path" do
      header "Accept", "application/json"
      header "Content-Type", "application/json"
      post "/required-body", {a: 5, b: "10"}.to_json

      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(last_response.body)).to eq("a" => 5, "b" => 10)
      expect(last_response.status).to eq(200)
    end
  end
end
