# frozen_string_literal: true

require 'modern/request'

describe Modern::Request do
  it "should generate a custom request id if none provided" do
    expect(Modern::Request.new({}).request_id).not_to be_nil
  end

  it "should honor an X-Request-Id that already exists" do
    expect(Modern::Request.new("HTTP_X_REQUEST_ID" => "hello").request_id).to eq("hello")
  end
end
