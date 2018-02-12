# frozen_string_literal: true

require 'modern/app'

require_relative './routes'

describe Modern::Descriptor::Security do
  include_context "security routes"

  let(:descriptor) do
    Modern::Descriptor::Core.new(
      info: Modern::Descriptor::Info.new(
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

  context "basic validation" do
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
