require 'modern/app'

describe Modern::App do
  context "an App with an empty Descriptor" do
    let(:app) do
      Modern::App.new(Modern::Description::Descriptor.new,
                      Modern::Configuration.new)
    end
    
    it "404s when hitting / with no route" do
      header "Accept", "application/json"
      get "/"

      expect(JSON.parse(last_response.body)).to eq("message" => "Not found")
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(last_response.status).to eq(404)
    end
  end
end
