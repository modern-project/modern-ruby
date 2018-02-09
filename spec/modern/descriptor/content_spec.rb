# frozen_string_literal: true

require 'modern/app'

# TODO: test - ensure that route output converters override app output converters

shared_context "content test" do
  let(:good_route_scalar) do
    Modern::Descriptor::Route.new(
      id: "getGoodRouteScalar",
      http_method: :GET,
      path: "/good-route-scalar",
      summary: "a working route that returns a scalar value",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              schema: Modern::Types::Strict::Int
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          5
        end
    )
  end

  let(:bad_route_scalar) do
    Modern::Descriptor::Route.new(
      id: "getBadRouteScalar",
      http_method: :GET,
      path: "/bad-route-scalar",
      summary: "a route that fails to return a scalar value",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              schema: Modern::Types::Strict::Int
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          "5"
        end
    )
  end

  let(:good_route_hash) do
    Modern::Descriptor::Route.new(
      id: "getGoodRouteHash",
      http_method: :GET,
      path: "/good-route-hash",
      summary: "a working route that returns a hash",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              schema: Modern::Types::Strict::Hash.strict(
                a: Modern::Types::Strict::String,
                b: Modern::Types::Coercible::Int
              )
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          { a: "foo", b: "10" }
        end
    )
  end

  let(:bad_route_hash) do
    Modern::Descriptor::Route.new(
      id: "getBadRouteHash",
      http_method: :GET,
      path: "/bad-route-hash",
      summary: "an invalid route that fails to return a hash",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              schema: Modern::Types::Strict::Hash.strict(
                a: Modern::Types::Strict::String,
                b: Modern::Types::Coercible::Int
              )
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          { a: "foo", b: nil }
        end
    )
  end

  let(:test_struct) do
    Class.new(Modern::Struct) do
      attribute :a, Modern::Types::Strict::String
      attribute :b, Modern::Types::Coercible::Int
    end
  end

  let(:good_route_struct) do
    Modern::Descriptor::Route.new(
      id: "getGoodRouteStruct",
      http_method: :GET,
      path: "/good-route-struct",
      summary: "a working route that returns a hash through a Modern::Struct",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              schema: test_struct
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          { a: "foo", b: "10" }
        end
    )
  end

  let(:bad_route_struct) do
    Modern::Descriptor::Route.new(
      id: "getBadRouteStruct",
      http_method: :GET,
      path: "/bad-route-struct",
      summary: "an invalid route that fails to return through a Modern::Struct",
      parameters: [],
      responses: [
        Modern::Descriptor::Response.new(
          http_code: :default,
          content: [
            Modern::Descriptor::Content.new(
              media_type: "application/json",
              schema: test_struct
            )
          ]
        )
      ],
      action:
        proc do |_req, _res, _params, _body|
          { a: "foo", b: nil }
        end
    )
  end

  let(:descriptor) do
    Modern::Descriptor::Core.new(
      info: Modern::OpenAPI3::Info.new(
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
    Modern::App.new(descriptor, cfg, base_logger: Ougai::Logger.new(StringIO.new))
  end
end

describe Modern::Descriptor::Content do
  context "basic validation" do
    include_context "content test"

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
