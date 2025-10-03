module OrionX
  class Client
    attr_reader :user, :orders, :accounts, :markets, :transactions, :api, :logger

    def initialize(api_key: nil, api_secret: nil, api_endpoint: nil, debug: false)
      # Configure the SDK if parameters are provided
      if api_key || api_secret || api_endpoint || debug
        OrionX.configure do |config|
          config.api_key = api_key if api_key
          config.api_secret = api_secret if api_secret
          config.api_endpoint = api_endpoint if api_endpoint
          config.debug = debug
        end
      end

      @api = OrionX::API.new
      @logger = @api.logger

      # Initialize endpoint modules
      @user = OrionX::Endpoints::User.new(@api)
      @orders = OrionX::Endpoints::Orders.new(@api)
      @accounts = OrionX::Endpoints::Accounts.new(@api)
      @markets = OrionX::Endpoints::Markets.new(@api)
      @transactions = OrionX::Endpoints::Transactions.new(@api)

      @logger.info("OrionX Client initialized successfully")
    end

    # Convenience method to get current user information
    def me
      @user.me
    end

    # Health check method
    def ping
      begin
        me
        { status: "ok", message: "Connection successful" }
      rescue => e
        { status: "error", message: e.message }
      end
    end

    # Enable/disable debug mode
    def debug=(enabled)
      OrionX.configuration.debug = enabled
      @logger.level = enabled ? ::Logger::DEBUG : ::Logger::INFO
      @logger.info("Debug mode #{enabled ? 'enabled' : 'disabled'}")
    end

    def debug?
      OrionX.configuration.debug?
    end
  end
end