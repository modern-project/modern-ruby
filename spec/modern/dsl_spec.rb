# frozen_string_literal: true

require 'modern/descriptor'
require 'modern/dsl'

describe Modern::DSL do
  it "builds a correct Info" do
    ret =
      Modern::Descriptor.from do
        info do
          title "Info Test"
          license "MIT", url: "https://opensource.org/licenses/MIT"
        end
      end

    expect(ret.info.title).to eq("Info Test")
    expect(ret.info.license.url).to eq("https://opensource.org/licenses/MIT")
  end

  it "appends input converters" do
    ret =
      Modern::Descriptor.from do
        input_converter "application/yaml" do |io|
          str = io.read
          str.empty? ? nil : YAML.safe_load(r.read)
        end

        input_converter Modern::Descriptor::Converters::Input::JSON
      end

    expect(ret.input_converters.length).to eq(2)
    expect(ret.input_converters.first.media_type).to eq("application/yaml")
    expect(ret.input_converters.last.media_type).to eq("application/json")
  end

  it "appends output converters" do
    ret =
      Modern::Descriptor.from do
        output_converter Modern::Descriptor::Converters::Output::JSON
      end

    expect(ret.output_converters.length).to eq(1)
    expect(ret.output_converters.last.media_type).to eq("application/json")
  end
end
