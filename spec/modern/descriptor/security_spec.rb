# frozen_string_literal: true

require 'modern/app'

shared_context "security test" do
  let(:http_bearer) do
    Modern::Descriptor::Route.new(
      id: "getHttpBearer",
      http_method: :GET,
      path: "/http-security/bearer",
      summary: "a route that tests for Bearer scheme in the Authorization header",
      security: [
        Modern::Descriptor::Security::Http.new(
          name: "httpBearerFoo",
          scheme: "Bearer",
          validation: proc { |v| v == "foo" }
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
        proc do
          { success: true }
        end
    )
  end

  let(:http_multi) do
    Modern::Descriptor::Route.new(
      id: "getHttpMulti",
      http_method: :GET,
      path: "/http-security/multi",
      summary: "a route that tests for a Bearer or NotBearer scheme in the Authorization header",
      security: [
        Modern::Descriptor::Security::Http.new(
          name: "httpMultiBearerFoo",
          scheme: "Bearer",
          validation: proc { |v| v == "foo" }
        ),
        Modern::Descriptor::Security::Http.new(
          name: "httpMultiNotBearerBar",
          scheme: "NotBearer",
          validation: proc { |v| v == "bar" }
        ),
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
        proc do
          { success: true }
        end
    )
  end

  let(:apikey_query) do
    Modern::Descriptor::Route.new(
      id: "getApiKeyQuery",
      http_method: :GET,
      path: "/apikey-security/query",
      summary: "a route that tests for a Token query parameter",
      security: [
        Modern::Descriptor::Security::ApiKey.new(
          name: "queryTokenFoo",
          parameter: Modern::Descriptor::Parameters::Query.new(
            name: "token",
            type: Modern::Types::Strict::String
          ),
          validation: proc { |v| v == "foo" }
        ),
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
        proc do
          { success: true }
        end
    )
  end

  let(:apikey_header) do
    Modern::Descriptor::Route.new(
      id: "getApiKeyHeader",
      http_method: :GET,
      path: "/apikey-security/header",
      summary: "a route that tests for a X-Modern-Token header",
      security: [
        Modern::Descriptor::Security::ApiKey.new(
          name: "headerFoo",
          parameter: Modern::Descriptor::Parameters::Header.new(
            name: "token",
            header_name: "X-Modern-Token",
            type: Modern::Types::Strict::String
          ),
          validation: proc { |v| v == "foo" }
        ),
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
        proc do
          { success: true }
        end
    )
  end

  let(:apikey_cookie) do
    Modern::Descriptor::Route.new(
      id: "getApiKeyCookie",
      http_method: :GET,
      path: "/apikey-security/cookie",
      summary: "a route that tests for a Modern-Token cookie",
      security: [
        Modern::Descriptor::Security::ApiKey.new(
          name: "cookieFoo",
          parameter: Modern::Descriptor::Parameters::Cookie.new(
            name: "token",
            cookie_name: "Modern-Token",
            type: Modern::Types::Strict::String
          ),
          validation: proc { |v| v == "foo" }
        ),
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
        proc do
          { success: true }
        end
    )
  end

  let(:descriptor) do
    Modern::Descriptor::Core.new(
      info: Modern::OpenAPI3::Info.new(
        title: "Security Spec",
        version: "1.0.0"
      ),
      routes: [
        http_bearer,
        http_multi,

        apikey_query,
        apikey_header,
        apikey_cookie
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
    # Modern::App.new(descriptor, cfg, Modern::Services.new(base_logger: Ougai::Logger.new(StringIO.new)))
    Modern::App.new(descriptor, cfg)
  end
end

describe Modern::Descriptor::Security do
  context "basic validation" do
    include_context "security test"

    context "http bearer" do
      it "returns 200 when the header validator succeeds" do
        header "Accept", "application/json"
        header "Authorization", "Bearer foo"
        get "/http-security/bearer"

        expect(last_response.status).to eq(200)
      end

      it "returns 401 when no header is detected" do
        header "Accept", "application/json"
        get "/http-security/bearer"

        expect(last_response.status).to eq(401)
      end

      it "returns 401 when the scheme is wrong" do
        header "Accept", "application/json"
        header "Authorization", "NotBearer bar"
        get "/http-security/bearer"

        expect(last_response.status).to eq(401)
      end

      it "returns 401 when the header validator fails" do
        header "Accept", "application/json"
        header "Authorization", "Bearer notfoo"
        get "/http-security/bearer"

        expect(last_response.status).to eq(401)
      end
    end

    context "http multi" do
      it "returns 200 when the first header validator succeeds" do
        header "Accept", "application/json"
        header "Authorization", "Bearer foo"
        get "/http-security/multi"

        expect(last_response.status).to eq(200)
      end

      it "returns 200 when the second header validator succeeds" do
        header "Accept", "application/json"
        header "Authorization", "NotBearer bar"
        get "/http-security/multi"

        expect(last_response.status).to eq(200)
      end

      it "returns 401 when the header validators fail" do
        header "Accept", "application/json"
        header "Authorization", "Bearer notfoo"
        get "/http-security/multi"

        expect(last_response.status).to eq(401)
      end
    end

    context "api key query" do
      it "returns 200 when query token exists" do
        header "Accept", "application/json"
        get "/apikey-security/query?token=foo"

        expect(last_response.status).to eq(200)
      end

      it "returns 401 when the token is missing" do
        header "Accept", "application/json"
        get "/apikey-security/query"

        expect(last_response.status).to eq(401)
      end

      it "returns 401 when the token validators fail" do
        header "Accept", "application/json"
        get "/apikey-security/query?token=bar"

        expect(last_response.status).to eq(401)
      end
    end

    context "api key header" do
      it "returns 200 when header exists" do
        header "Accept", "application/json"
        header "X-Modern-Token", "foo"
        get "/apikey-security/header"

        expect(last_response.status).to eq(200)
      end

      it "returns 401 when the token is missing" do
        header "Accept", "application/json"
        get "/apikey-security/header"

        expect(last_response.status).to eq(401)
      end

      it "returns 401 when the token validators fail" do
        header "Accept", "application/json"
        header "X-Modern-Token", "bar"
        get "/apikey-security/header"

        expect(last_response.status).to eq(401)
      end
    end

    context "api key cookie" do
      it "returns 200 when header exists" do
        clear_cookies
        set_cookie "Modern-Token=foo"
        header "Accept", "application/json"
        get "/apikey-security/cookie"

        expect(last_response.status).to eq(200)
      end

      it "returns 401 when the token is missing" do
        clear_cookies
        header "Accept", "application/json"
        get "/apikey-security/cookie"

        expect(last_response.status).to eq(401)
      end

      it "returns 401 when the token validators fail" do
        clear_cookies
        set_cookie "Modern-Token=bar"
        header "Accept", "application/json"
        get "/apikey-security/cookie"

        expect(last_response.status).to eq(401)
      end
    end
  end
end
