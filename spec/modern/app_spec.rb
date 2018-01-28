require 'modern/app'

describe Modern::App do
  context "an App with an empty Descriptor" do
    let (:descriptor) do
      Modern::Descriptor.new
    end

    let(:app) do
      Modern::App.new(descriptor)
    end
    
    it "404s when hitting / with no route" do
      header "Accept", "application/json"
      get "/"

      expect(JSON.parse(last_response.body)).to eq("message" => "Not found")
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(last_response.status).to eq(404)
    end

    it "returns an X-Response-Id header with its responses" do
      header "Accept", "application/json"
      get "/"

      id1 = last_response.headers["X-Response-Id"]
      
      header "Accept", "application/json"
      get "/"

      id2 = last_response.headers["X-Response-Id"]

      expect(id1).not_to be_nil
      expect(id2).not_to be_nil
      expect(id1).not_to eq(id2)
    end
  end
end
