# frozen_string_literal: true

require 'modern/app'

shared_context "parameter test" do
  let(:query_route) do
    Modern::Descriptor::Route.new(
      id: "getQuery",
      http_method: :GET,
      path: "/query-form",
      summary: "A query parameter",
      parameters: [
        Modern::Descriptor::Parameters::Query.new(
          name: "a",
          type: Modern::Types::Coercible::Int,
          required: true
        ),
        Modern::Descriptor::Parameters::Query.new(
          name: "b",
          type: Modern::Types::Coercible::String,
          required: true
        ),
        Modern::Descriptor::Parameters::Query.new(
          name: "c",
          type: Modern::Types::Coercible::Int,
          required: false
        )
      ],
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
      action:
        proc do |req, res, params, body|
          res.json(params)
        end
    )
  end

  let(:header_route) do
    Modern::Descriptor::Route.new(
      id: "getHeader",
      http_method: :GET,
      path: "/header-simple",
      summary: "A header parameter",
      parameters: [
        Modern::Descriptor::Parameters::Header.new(
          name: "a",
          header_name: "My-Header-A",
          type: Modern::Types::Coercible::Int,
          required: true
        ),
        Modern::Descriptor::Parameters::Header.new(
          name: "b",
          header_name: "My-Header-B",
          type: Modern::Types::Coercible::String,
          required: true
        ),
        Modern::Descriptor::Parameters::Header.new(
          name: "c",
          header_name: "My-Header-C",
          type: Modern::Types::Coercible::Int,
          required: false
        )
      ],
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
      action:
        proc do |req, res, params, body|
          res.json(params)
        end
    )
  end

  let(:cookie_route) do
    Modern::Descriptor::Route.new(
      id: "getCookie",
      http_method: :GET,
      path: "/cookie-form",
      summary: "A cookie parameter",
      parameters: [
        Modern::Descriptor::Parameters::Cookie.new(
          name: "a",
          cookie_name: "My-Cookie-A",
          type: Modern::Types::Coercible::Int,
          required: true
        ),
        Modern::Descriptor::Parameters::Cookie.new(
          name: "b",
          cookie_name: "My-Cookie-B",
          type: Modern::Types::Coercible::String,
          required: true
        ),
        Modern::Descriptor::Parameters::Cookie.new(
          name: "c",
          cookie_name: "My-Cookie-C",
          type: Modern::Types::Coercible::Int,
          required: false
        )
      ],
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
      action:
        proc do |req, res, params, body|
          res.json(params)
        end
    )
  end

  let(:descriptor) do
    Modern::Descriptor::Core.new(
      info: Modern::OpenAPI3::Info.new(
        title: "Parameter Spec",
        version: "1.0.0"
      ),
      routes: [
        query_route,
        header_route,
        cookie_route
      ],
      security_schemes: []
    )
  end

  let(:app) do
    Modern::App::TrieRouter.new(routes: descriptor.routes)
  end

  let(:app) do
    Modern::App.new(descriptor)
  end
end

describe Modern::Descriptor::Parameters do
  context "basic types of parameters" do
    include_context "parameter test"

    it "parses a form-encoded query parameter" do
      header "Accept", "application/json"
      get "/query-form?a=5&b=something"

      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(last_response.body)).to eq("a" => 5, "b" => "something", "c" => nil)
      expect(last_response.status).to eq(200)
    end

    it "fails when query parameters are required and not available" do
      header "Accept", "application/json"
      get "/query-form?a=5"

      expect(last_response.body).to include("'b'")
      expect(last_response.status).to eq(400)
    end

    it "parses a simple-encoded header parameter" do
      header "Accept", "application/json"
      header "My-Header-A", "5"
      header "My-Header-B", "something"
      get "/header-simple"

      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(last_response.body)).to eq("a" => 5, "b" => "something", "c" => nil)
      expect(last_response.status).to eq(200)
    end

    it "fails when header parameters are required and not available" do
      header "Accept", "application/json"
      header "My-Header-A", "5"
      get "/header-simple"

      expect(last_response.body).to include("'My-Header-B'")
      expect(last_response.status).to eq(400)
    end

    it "parses a path parameter" do

    end

    it "parses a form-encoded cookie parameter" do
      clear_cookies
      set_cookie "My-Cookie-A=5"
      set_cookie "My-Cookie-B=something"
      header "Accept", "application/json"
      get "/cookie-form"

      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(last_response.body)).to eq("a" => 5, "b" => "something", "c" => nil)
      expect(last_response.status).to eq(200)
    end

    it "fails when cookie parameters are required and not available" do
      clear_cookies
      set_cookie "My-Cookie-A=5"
      header "Accept", "application/json"
      get "/cookie-form"

      expect(last_response.body).to include("'My-Cookie-B'")
      expect(last_response.status).to eq(400)
    end
  end
end
