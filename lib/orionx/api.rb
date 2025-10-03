require "faraday"
require "json"
require "openssl"

module OrionX
  class API
    attr_reader :api_key, :api_secret, :api_endpoint, :config, :logger

    def initialize(api_key: nil, api_secret: nil, api_endpoint: nil, config: nil)
      @config = config || OrionX.configuration
      @api_key = api_key || @config.api_key
      @api_secret = api_secret || @config.api_secret
      @api_endpoint = api_endpoint || @config.api_endpoint
      @logger = @config.logger

      validate_credentials!
      setup_connection
    end

    def call(query, variables = {})
      retries = 0
      begin
        @logger.debug("GraphQL Query: #{query}")
        @logger.debug("Variables: #{variables.inspect}")

        response = execute_request(query, variables)
        handle_response(response)
      rescue Faraday::TimeoutError => e
        @logger.error("Request timeout: #{e.message}")
        raise OrionX::NetworkError, "Request timeout: #{e.message}"
      rescue Faraday::ConnectionFailed => e
        @logger.error("Connection failed: #{e.message}")
        raise OrionX::NetworkError, "Connection failed: #{e.message}"
      rescue OrionX::APIError => e
        if retries < @config.retries && retryable_error?(e)
          retries += 1
          @logger.warn("Retrying request (attempt #{retries}/#{@config.retries}): #{e.message}")
          sleep(backoff_delay(retries))
          retry
        else
          raise e
        end
      rescue => e
        @logger.error("Unexpected error: #{e.message}")
        @logger.debug("Backtrace: #{e.backtrace.join("\n")}")
        raise OrionX::Error, "Unexpected error: #{e.message}"
      end
    end

    private

    def validate_credentials!
      raise OrionX::AuthenticationError, "API key is required" if @api_key.nil? || @api_key.empty?
      raise OrionX::AuthenticationError, "API secret is required" if @api_secret.nil? || @api_secret.empty?
      raise OrionX::ValidationError, "API endpoint is required" if @api_endpoint.nil? || @api_endpoint.empty?
    end

    def setup_connection
      @connection = Faraday.new(@api_endpoint) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.options.timeout = @config.timeout
        conn.adapter Faraday.default_adapter
        
        if @config.debug?
          conn.response :logger, @logger.logger, bodies: true, headers: true
        end
      end
      
      @logger.info("API connection established to #{@api_endpoint}")
    end

    def execute_request(query, variables)
      timestamp = Time.now.to_f
      body = JSON.generate({ query: query, variables: variables })
      signature = generate_signature(timestamp.to_s, body)

      headers = {
        "X-ORIONX-TIMESTAMP" => timestamp.to_s,
        "X-ORIONX-APIKEY" => @api_key,
        "X-ORIONX-SIGNATURE" => signature,
        "Content-Type" => "application/json"
      }

      @logger.debug("Request headers: #{headers.inspect}")
      @logger.debug("Request body: #{body}")

      response = @connection.post do |req|
        req.headers.merge!(headers)
        req.body = body
      end

      @logger.debug("Response status: #{response.status}")
      @logger.debug("Response body: #{response.body.inspect}")

      response
    end

    def generate_signature(timestamp, body)
      data = timestamp + body
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha512"), @api_secret, data)
      @logger.debug("Generated signature for timestamp #{timestamp}")
      signature
    end

    def handle_response(response)
      case response.status
      when 200
        handle_success_response(response.body)
      when 401
        @logger.error("Authentication failed")
        raise OrionX::AuthenticationError, "Authentication failed: Invalid API credentials"
      when 429
        @logger.error("Rate limit exceeded")
        raise OrionX::RateLimitError, "Rate limit exceeded"
      when 500
        @logger.error("Internal server error")
        raise OrionX::APIError, "Internal server error"
      else
        @logger.error("Unexpected response status: #{response.status}")
        raise OrionX::APIError, "HTTP #{response.status}: #{response.body}"
      end
    end

    def handle_success_response(body)
      return {} if body.nil? || body.empty?

      if body.is_a?(String)
        begin
          parsed_body = JSON.parse(body)
        rescue JSON::ParserError => e
          @logger.error("Failed to parse response JSON: #{e.message}")
          raise OrionX::APIError, "Invalid JSON response: #{e.message}"
        end
      else
        parsed_body = body
      end

      if parsed_body.key?("errors") && !parsed_body["errors"].empty?
        error_message = parsed_body["errors"].first["message"]
        @logger.error("GraphQL error: #{error_message}")

        # Check if we have partial data
        if parsed_body.key?("data") && !parsed_body["data"].nil?
          errors_count = parsed_body["errors"].length
          data_keys_count = parsed_body["data"].keys.length
          
          # Return data if errors don't affect all fields
          return parsed_body["data"] if errors_count < data_keys_count
        end

        raise OrionX::APIError, "GraphQL error: #{error_message}"
      end

      parsed_body["data"] || {}
    end

    def retryable_error?(error)
      error.is_a?(OrionX::RateLimitError) || 
        (error.is_a?(OrionX::APIError) && error.message.include?("500"))
    end

    def backoff_delay(attempt)
      # Exponential backoff: 1s, 2s, 4s
      2 ** (attempt - 1)
    end
  end
end