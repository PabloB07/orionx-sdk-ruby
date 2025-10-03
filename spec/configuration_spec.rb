require "spec_helper"

RSpec.describe OrionX::Configuration do
  describe "#initialize" do
    it "sets default values" do
      config = OrionX::Configuration.new
      
      expect(config.api_key).to be_nil
      expect(config.api_secret).to be_nil
      expect(config.api_endpoint).to eq("https://api2.orionx.io/graphql")
      expect(config.debug).to be_falsey
      expect(config.timeout).to eq(30)
      expect(config.retries).to eq(3)
    end
  end

  describe "#valid?" do
    it "returns false when credentials are missing" do
      config = OrionX::Configuration.new
      expect(config.valid?).to be_falsey
    end

    it "returns true when all required credentials are present" do
      config = OrionX::Configuration.new
      config.api_key = "test_key"
      config.api_secret = "test_secret"
      
      expect(config.valid?).to be_truthy
    end
  end

  describe "#debug?" do
    it "returns false by default" do
      config = OrionX::Configuration.new
      expect(config.debug?).to be_falsey
    end

    it "returns true when debug is enabled" do
      config = OrionX::Configuration.new
      config.debug = true
      expect(config.debug?).to be_truthy
    end
  end
end

RSpec.describe OrionX do
  describe ".configure" do
    it "yields configuration object" do
      expect { |b| OrionX.configure(&b) }.to yield_with_args(OrionX::Configuration)
    end

    it "sets configuration values" do
      OrionX.configure do |config|
        config.api_key = "test_key"
        config.debug = true
      end

      expect(OrionX.configuration.api_key).to eq("test_key")
      expect(OrionX.configuration.debug).to be_truthy
    end
  end

  describe ".configuration" do
    it "returns the same instance" do
      config1 = OrionX.configuration
      config2 = OrionX.configuration
      
      expect(config1).to be(config2)
    end
  end
end