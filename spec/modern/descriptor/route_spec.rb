# frozen_string_literal: true

describe Modern::Descriptor::Route do
  context "helper integration with request container" do
    include_context "helpers routes"

    let(:descriptor) do
      Modern::Descriptor::Core.new(
        info: Modern::Descriptor::Info.new(
          title: "Helpers Spec",
          version: "1.0.0"
        ),
        routes: [
          helper_route
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
      # Modern::App.new(descriptor, cfg)
      Modern::App.new(descriptor, cfg, Modern::Services.new(base_logger: Ougai::Logger.new(StringIO.new)))
    end

    it "should correctly generate a FullRequestContainer subclass with helpers included" do
      expect(helper_route.request_container_class.ancestors) \
        .to include(Modern::App::RequestHandling::FullRequestContainer)

      expect(helper_route.request_container_class.ancestors) \
        .to include(HelpersTest::Helper)
    end

    it "should invoke helper methods inside an executed route" do
      header "Accept", "application/json"
      get "/helper-value"

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to eq("a" => "this is from my helper")
    end
  end
end
