module OrionX
  module Endpoints
    class Markets
      def initialize(api_client)
        @api = api_client
        @logger = api_client.logger
      end

      # Get information for a specific market
      def get_market(market_code)
        raise OrionX::ValidationError, "Market code cannot be nil or empty" if market_code.nil? || market_code.empty?

        query = <<~GRAPHQL
          query sdk_market($code: ID) {
            market(code: $code) {
              code
              name
              mainCurrency {
                code
                name
                units
              }
              secondaryCurrency {
                code
                name
                units
              }
              lastTrade {
                price
              }
            }
          }
        GRAPHQL

        @logger.debug("Fetching market data for: #{market_code}")
        response = @api.call(query, { code: market_code })
        
        result = response.dig("market")
        @logger.info("Market #{market_code} data retrieved successfully") if result
        result
      end

      # Get all available markets
      def get_markets
        query = <<~GRAPHQL
          query sdk_markets {
            markets {
              code
              name
              mainCurrency {
                code
                name
                units
              }
              secondaryCurrency {
                code
                name
                units
              }
              lastTrade {
                price
              }
            }
          }
        GRAPHQL

        @logger.debug("Fetching all markets")
        response = @api.call(query)
        
        result = response.dig("markets")
        @logger.info("All markets retrieved: #{result&.length || 0} markets") if result
        result
      end

      # Get order book for a specific market
      def get_orderbook(market_code, limit: 50)
        raise OrionX::ValidationError, "Market code cannot be nil or empty" if market_code.nil? || market_code.empty?
        raise OrionX::ValidationError, "Limit must be positive" if limit <= 0

        query = <<~GRAPHQL
          query sdk_marketOrderBook($marketCode: ID!, $limit: Int) {
            marketOrderBook(marketCode: $marketCode, limit: $limit) {
              sell {
                amount
                limitPrice
              }
              buy {
                amount
                limitPrice
              }
              spread
              mid
            }
          }
        GRAPHQL

        @logger.debug("Fetching orderbook for #{market_code} (limit: #{limit})")
        response = @api.call(query, { marketCode: market_code, limit: limit })
        
        result = response.dig("marketOrderBook")
        if result
          @logger.info("Orderbook for #{market_code} retrieved - Buy orders: #{result.dig('buy')&.length || 0}, Sell orders: #{result.dig('sell')&.length || 0}")
        end
        result
      end

      # Get market statistics
      def get_market_stats(market_code)
        market = get_market(market_code)
        orderbook = get_orderbook(market_code, limit: 1)

        return nil unless market && orderbook

        {
          code: market["code"],
          name: market["name"],
          last_price: market.dig("lastTrade", "price"),
          spread: orderbook["spread"],
          mid_price: orderbook["mid"],
          best_bid: orderbook.dig("buy", 0, "limitPrice"),
          best_ask: orderbook.dig("sell", 0, "limitPrice"),
          main_currency: market.dig("mainCurrency", "code"),
          secondary_currency: market.dig("secondaryCurrency", "code")
        }
      end
    end
  end
end