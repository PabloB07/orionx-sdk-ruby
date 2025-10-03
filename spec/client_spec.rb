require "spec_helper"

RSpec.describe OrionX::Client do
  before do
    configure_orionx
  end

  describe "#initialize" do
    it "creates a client with default configuration" do
      client = OrionX::Client.new
      expect(client).to be_a(OrionX::Client)
      expect(client.user).to be_a(OrionX::Endpoints::User)
      expect(client.orders).to be_a(OrionX::Endpoints::Orders)
      expect(client.accounts).to be_a(OrionX::Endpoints::Accounts)
      expect(client.markets).to be_a(OrionX::Endpoints::Markets)
      expect(client.transactions).to be_a(OrionX::Endpoints::Transactions)
    end

    it "accepts configuration parameters" do
      client = OrionX::Client.new(
        api_key: "custom_key",
        api_secret: "custom_secret",
        debug: true
      )

      expect(OrionX.configuration.api_key).to eq("custom_key")
      expect(OrionX.configuration.api_secret).to eq("custom_secret")
      expect(OrionX.configuration.debug).to be_truthy
    end
  end

  describe "#me" do
    it "delegates to user endpoint" do
      client = OrionX::Client.new
      
      stub_graphql_request(/getMe/, {
        me: {
          _id: "user123",
          email: "test@example.com",
          name: "Test User"
        }
      })

      result = client.me
      expect(result["_id"]).to eq("user123")
    end
  end

  describe "#ping" do
    context "when connection is successful" do
      it "returns success status" do
        client = OrionX::Client.new
        
        stub_graphql_request(/getMe/, {
          me: { _id: "user123" }
        })

        result = client.ping
        expect(result[:status]).to eq("ok")
        expect(result[:message]).to eq("Connection successful")
      end
    end

    context "when connection fails" do
      it "returns error status" do
        client = OrionX::Client.new
        
        stub_request(:post, "https://api2.test.orionx.io/graphql")
          .to_return(status: 401)

        result = client.ping
        expect(result[:status]).to eq("error")
        expect(result[:message]).to include("Authentication failed")
      end
    end
  end

  describe "#debug=" do
    it "updates debug configuration" do
      client = OrionX::Client.new
      
      expect(client.debug?).to be_falsey
      
      client.debug = true
      expect(client.debug?).to be_truthy
      expect(OrionX.configuration.debug).to be_truthy
    end
  end
end