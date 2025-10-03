module OrionX
  module Endpoints
    class Transactions
      def initialize(api_client)
        @api = api_client
        @logger = api_client.logger
      end

      # Get a specific transaction by ID
      def get_transaction(transaction_id)
        raise OrionX::ValidationError, "Transaction ID cannot be nil or empty" if transaction_id.nil? || transaction_id.empty?

        query = <<~GRAPHQL
          query sdk_getTransaction($_id: ID!) {
            transaction(_id: $_id) {
              _id
              amount
              balance
              commission
              currency {
                code
                units
              }
              date
              type
              adds
              hash
              description
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
              price
              cost
              explorerURL
              isInside
              meta {
                status
              }
            }
          }
        GRAPHQL

        @logger.debug("Fetching transaction: #{transaction_id}")
        response = @api.call(query, { _id: transaction_id })
        
        result = response.dig("transaction")
        @logger.info("Transaction #{transaction_id} retrieved successfully") if result
        result
      end

      # Get transactions with optional filters
      def get_transactions(filters = {})
        query = <<~GRAPHQL
          query sdk_getTransactions($filter: String, $walletId: ID, $types: [String], $initPeriod: Date, $finalPeriod: Date, $page: Int, $limit: Int, $sortBy: String, $sortType: SortType) {
            transactions(filter: $filter, walletId: $walletId, types: $types, initPeriod: $initPeriod, finalPeriod: $finalPeriod, page: $page, limit: $limit, sortBy: $sortBy, sortType: $sortType) {
              _id
              items {
                amount
                balance
                commission
                currency {
                  code
                  units
                }
                date
                type
                adds
                hash
                description
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
                price
                cost
                explorerURL
                isInside
                meta {
                  status
                }
              }
            }
          }
        GRAPHQL

        @logger.debug("Fetching transactions with filters: #{filters.inspect}")
        response = @api.call(query, filters)
        
        result = response.dig("transactions")
        @logger.info("Transactions retrieved: #{result&.dig('items')&.length || 0} transactions") if result
        result
      end

      # Send cryptocurrency
      def send_crypto(wallet_id:, network:, amount:, contact_id: nil, description: nil, client_id: nil)
        raise OrionX::ValidationError, "Wallet ID cannot be nil or empty" if wallet_id.nil? || wallet_id.empty?
        raise OrionX::ValidationError, "Network cannot be nil or empty" if network.nil? || network.empty?
        raise OrionX::ValidationError, "Amount must be positive" if amount.nil? || amount <= 0

        query = <<~GRAPHQL
          mutation sdk_send(
            $fromWalletId: ID!
            $contactId: ID
            $network: String!
            $amount: BigInt!
            $description: String
            $clientId: ID
          ) {
            sendCrypto(
              fromWalletId: $fromWalletId
              contactId: $contactId
              network: $network
              amount: $amount
              description: $description
              clientId: $clientId
            ) {
              _id
              type
              amount
              price
              hash
              date
              market {
                code
              }
              meta { 
                status
              }
            }
          }
        GRAPHQL

        variables = {
          fromWalletId: wallet_id,
          contactId: contact_id,
          network: network,
          amount: amount,
          description: description,
          clientId: client_id
        }

        @logger.debug("Sending crypto: #{variables.inspect}")
        response = @api.call(query, variables)
        
        result = response.dig("sendCrypto")
        @logger.info("Crypto send initiated successfully: #{result&.dig('_id')}") if result
        result
      end

      # Request withdrawal
      def withdrawal_request(wallet_id:, account_id:, amount:)
        raise OrionX::ValidationError, "Wallet ID cannot be nil or empty" if wallet_id.nil? || wallet_id.empty?
        raise OrionX::ValidationError, "Account ID cannot be nil or empty" if account_id.nil? || account_id.empty?
        raise OrionX::ValidationError, "Amount must be positive" if amount.nil? || amount <= 0

        query = <<~GRAPHQL
          mutation sdk_withdrawalRequest(
            $walletId: ID
            $accountId: ID
            $amount: BigInt
          ) {
            requestWithdrawal(
              walletId: $walletId
              accountId: $accountId
              amount: $amount
            ) {
              _id
              amount
              commission
              date
              type
              description
            }
          }
        GRAPHQL

        variables = {
          walletId: wallet_id,
          accountId: account_id,
          amount: amount
        }

        @logger.debug("Requesting withdrawal: #{variables.inspect}")
        response = @api.call(query, variables)
        
        result = response.dig("requestWithdrawal")
        @logger.info("Withdrawal request created successfully: #{result&.dig('_id')}") if result
        result
      end

      # Convert/Trade instantly
      def convert(quote_option_id:, amount:, market_code:, sell:)
        raise OrionX::ValidationError, "Quote option ID cannot be nil or empty" if quote_option_id.nil? || quote_option_id.empty?
        raise OrionX::ValidationError, "Amount must be positive" if amount.nil? || amount <= 0
        raise OrionX::ValidationError, "Market code cannot be nil or empty" if market_code.nil? || market_code.empty?

        query = <<~GRAPHQL
          mutation sdk_convert(
            $quoteOptionId: String
            $amount: BigInt!
            $marketCode: String!
            $sell: Boolean!
          ) {
            instantTransaction(
              quoteOptionId: $quoteOptionId
              amount: $amount
              marketCode: $marketCode
              sell: $sell
            )
          }
        GRAPHQL

        variables = {
          quoteOptionId: quote_option_id,
          amount: amount,
          marketCode: market_code,
          sell: sell
        }

        @logger.debug("Converting/trading instantly: #{variables.inspect}")
        response = @api.call(query, variables)
        
        result = response.dig("instantTransaction")
        @logger.info("Instant conversion completed successfully") if result
        result
      end

      # Get transaction history for a specific currency
      def get_history(currency_code, limit: 50, page: 1)
        # First get the wallet ID for the currency
        account_query = <<~GRAPHQL
          query sdk_getAccount($assetId: ID!) {
            wallet(code: $assetId) {
              _id
            }
          }
        GRAPHQL

        account_response = @api.call(account_query, { assetId: currency_code })
        wallet_id = account_response.dig("wallet", "_id")

        return nil unless wallet_id

        # Get transactions for this wallet
        get_transactions({
          walletId: wallet_id,
          limit: limit,
          page: page,
          sortType: "DESC"
        })
      end
    end
  end
end