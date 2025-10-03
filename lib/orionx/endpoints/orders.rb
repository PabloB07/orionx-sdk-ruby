module OrionX
  module Endpoints
    class Orders
      def initialize(api_client)
        @api = api_client
        @logger = api_client.logger
      end

      # Get a specific order by ID
      def get_order(order_id)
        raise OrionX::ValidationError, "Order ID cannot be nil or empty" if order_id.nil? || order_id.empty?

        query = <<~GRAPHQL
          query sdk_getOrder($orderId: ID!) {
            order(orderId: $orderId) {
              _id
              type
              amount
              limitPrice
              stopPriceDown
              stopPriceUp
              status
              createdAt
              activatedAt
              closedAt
              market {
                code
                mainCurrency {
                  code
                  units
                }
                secondaryCurrency {
                  code
                  units
                }
              }
              clientId
            }
          }
        GRAPHQL

        @logger.debug("Fetching order: #{order_id}")
        response = @api.call(query, { orderId: order_id })
        
        result = response.dig("order")
        @logger.info("Order #{order_id} retrieved successfully") if result
        result
      end

      # Get orders with optional filters
      def get_orders(filters = {})
        query = <<~GRAPHQL
          query sdk_getOrders($filter: String, $marketCode: ID, $onlyOpen: Boolean, $onlyClosed: Boolean, $currencyCode: ID, $onlyFilled: Boolean, $page: Int, $limit: Int, $sortBy: String, $sortType: SortType) {
            orders(filter: $filter, marketCode: $marketCode, onlyOpen: $onlyOpen, onlyClosed: $onlyClosed, currencyCode: $currencyCode, onlyFilled: $onlyFilled, page: $page, limit: $limit, sortBy: $sortBy, sortType: $sortType) {
              _id
              items {
                type
                amount
                limitPrice
                stopPriceUp
                stopPriceDown
                status
                createdAt
                activatedAt
                closedAt
                market {
                  code
                  mainCurrency {
                    code
                    units
                  }
                  secondaryCurrency {
                    code
                    units
                  }
                }
                clientId
              }
            }
          }
        GRAPHQL

        @logger.debug("Fetching orders with filters: #{filters.inspect}")
        response = @api.call(query, filters)
        
        result = response.dig("orders")
        @logger.info("Orders retrieved: #{result&.dig('items')&.length || 0} orders") if result
        result
      end

      # Place a limit order
      def place_limit_order(market_code:, amount:, limit_price:, sell:, client_id: nil)
        validate_order_params(market_code, amount)
        raise OrionX::ValidationError, "Limit price must be positive" if limit_price.nil? || limit_price <= 0

        query = <<~GRAPHQL
          mutation sdk_placeLimitOrder(
            $marketCode: ID
            $amount: BigInt
            $limitPrice: BigInt
            $sell: Boolean
            $clientId: String
          ) {
            placeLimitOrder(
              marketCode: $marketCode
              amount: $amount
              limitPrice: $limitPrice
              sell: $sell
              clientId: $clientId
            ) {
              _id
              type
              amount
              limitPrice
              status
              createdAt
              market {
                code
              }
              clientId
            }
          }
        GRAPHQL

        variables = {
          marketCode: market_code,
          amount: amount,
          limitPrice: limit_price,
          sell: sell,
          clientId: client_id
        }

        @logger.debug("Placing limit order: #{variables.inspect}")
        response = @api.call(query, variables)
        
        result = response.dig("placeLimitOrder")
        @logger.info("Limit order placed successfully: #{result&.dig('_id')}") if result
        result
      end

      # Place a market order
      def place_market_order(market_code:, amount:, sell:, client_id: nil)
        validate_order_params(market_code, amount)

        query = <<~GRAPHQL
          mutation sdk_placeMarketOrder(
            $marketCode: ID
            $amount: BigInt
            $sell: Boolean
            $clientId: String
          ) {
            placeMarketOrder(
              marketCode: $marketCode
              amount: $amount
              sell: $sell
              clientId: $clientId
            ) {
              _id
              type
              amount
              limitPrice
              status
              createdAt
              market {
                code
              }
              clientId
            }
          }
        GRAPHQL

        variables = {
          marketCode: market_code,
          amount: amount,
          sell: sell,
          clientId: client_id
        }

        @logger.debug("Placing market order: #{variables.inspect}")
        response = @api.call(query, variables)
        
        result = response.dig("placeMarketOrder")
        @logger.info("Market order placed successfully: #{result&.dig('_id')}") if result
        result
      end

      # Place a stop limit order
      def place_stop_limit_order(market_code:, stop_price_up:, stop_price_down:, amount:, limit_price:, sell:, client_id: nil)
        validate_order_params(market_code, amount)
        raise OrionX::ValidationError, "Limit price must be positive" if limit_price.nil? || limit_price <= 0
        raise OrionX::ValidationError, "At least one stop price must be provided" if stop_price_up.nil? && stop_price_down.nil?

        query = <<~GRAPHQL
          mutation sdk_placeStopLimitOrder(
            $marketCode: ID
            $stopPriceUp: BigInt
            $stopPriceDown: BigInt
            $amount: BigInt
            $limitPrice: BigInt
            $sell: Boolean
            $clientId: String
          ) {
            placeStopLimitOrder(
              marketCode: $marketCode
              stopPriceUp: $stopPriceUp
              stopPriceDown: $stopPriceDown
              amount: $amount
              limitPrice: $limitPrice
              sell: $sell
              clientId: $clientId
            ) {
              _id
              type
              amount
              limitPrice
              status
              createdAt
              market {
                code
              }
              clientId
            }
          }
        GRAPHQL

        variables = {
          marketCode: market_code,
          stopPriceUp: stop_price_up,
          stopPriceDown: stop_price_down,
          amount: amount,
          limitPrice: limit_price,
          sell: sell,
          clientId: client_id
        }

        @logger.debug("Placing stop limit order: #{variables.inspect}")
        response = @api.call(query, variables)
        
        result = response.dig("placeStopLimitOrder")
        @logger.info("Stop limit order placed successfully: #{result&.dig('_id')}") if result
        result
      end

      # Place a stop market order
      def place_stop_market_order(market_code:, stop_price_up:, stop_price_down:, amount:, sell:, client_id: nil)
        validate_order_params(market_code, amount)
        raise OrionX::ValidationError, "At least one stop price must be provided" if stop_price_up.nil? && stop_price_down.nil?

        query = <<~GRAPHQL
          mutation sdk_placeStopMarketOrder(
            $marketCode: ID
            $stopPriceUp: BigInt
            $stopPriceDown: BigInt
            $amount: BigInt
            $sell: Boolean
            $clientId: String
          ) {
            placeStopMarketOrder(
              marketCode: $marketCode
              stopPriceUp: $stopPriceUp
              stopPriceDown: $stopPriceDown
              amount: $amount
              sell: $sell
              clientId: $clientId
            ) {
              _id
              type
              amount
              limitPrice
              status
              createdAt
              market {
                code
              }
              clientId
            }
          }
        GRAPHQL

        variables = {
          marketCode: market_code,
          stopPriceUp: stop_price_up,
          stopPriceDown: stop_price_down,
          amount: amount,
          sell: sell,
          clientId: client_id
        }

        @logger.debug("Placing stop market order: #{variables.inspect}")
        response = @api.call(query, variables)
        
        result = response.dig("placeStopMarketOrder")
        @logger.info("Stop market order placed successfully: #{result&.dig('_id')}") if result
        result
      end

      # Cancel an order
      def cancel_order(order_id)
        raise OrionX::ValidationError, "Order ID cannot be nil or empty" if order_id.nil? || order_id.empty?

        query = <<~GRAPHQL
          mutation sdk_cancelOrder($orderId: ID!) {
            cancelOrder(orderId: $orderId) {
              _id
              type
              status
              clientId
            }
          }
        GRAPHQL

        @logger.debug("Cancelling order: #{order_id}")
        response = @api.call(query, { orderId: order_id })
        
        result = response.dig("cancelOrder")
        @logger.info("Order #{order_id} cancelled successfully") if result
        result
      end

      private

      def validate_order_params(market_code, amount)
        raise OrionX::ValidationError, "Market code cannot be nil or empty" if market_code.nil? || market_code.empty?
        raise OrionX::ValidationError, "Amount must be positive" if amount.nil? || amount <= 0
      end
    end
  end
end