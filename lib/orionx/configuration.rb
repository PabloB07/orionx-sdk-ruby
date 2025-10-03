require "logger"

module OrionX
  class Configuration
    attr_accessor :api_key, :api_secret, :api_endpoint, :debug, :logger, :timeout, :retries

    def initialize
      @api_key = nil
      @api_secret = nil
      @api_endpoint = "https://api2.orionx.io/graphql"
      @debug = false
      @logger = nil
      @timeout = 30
      @retries = 3
    end

    def valid?
      !api_key.nil? && !api_secret.nil? && !api_endpoint.nil?
    end

    def logger
      @logger ||= OrionX::Logger.new(level: debug? ? ::Logger::DEBUG : ::Logger::INFO)
    end

    def debug?
      @debug
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      configuration.logger.debug("OrionX SDK configured with endpoint: #{configuration.api_endpoint}")
      configuration.logger.debug("Debug mode: #{configuration.debug?}")
    end
  end
end