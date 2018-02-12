# frozen_string_literal: true

require 'modern/app'

require_relative './routes'

describe Modern::Descriptor::Parameters do
  include_context "parameter routes"

  let(:descriptor) do
    Modern::Descriptor::Core.new(
      info: Modern::Descriptor::Info.new(
        title: "Parameter Spec",
        version: "1.0.0"
      ),
      routes: [
        query_route,
        header_route,
        cookie_route,
        path_route
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
    Modern::App.new(descriptor)
  end

  context "basic types of parameters" do
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
      header "Accept", "application/json"
      get "/path-simple/5/something/10"

      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(last_response.body)).to eq("a" => 5, "b" => "something", "c" => 10)
      expect(last_response.status).to eq(200)
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
