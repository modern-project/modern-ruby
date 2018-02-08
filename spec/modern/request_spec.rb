# frozen_string_literal: true

require 'modern/request'

require 'ougai'

describe Modern::Request do
  let(:logger) do
    Ougai::Logger.new($stderr)
  end

  it "should generate a custom request id if none provided" do
    expect(Modern::Request.new({}, logger).request_id).not_to be_nil
  end

  it "should honor an X-Request-Id that already exists" do
    expect(Modern::Request.new({ "HTTP_X_REQUEST_ID" => "hello" }, logger).request_id).to eq("hello")
  end
end
