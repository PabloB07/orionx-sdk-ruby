module OrionX
  module Endpoints
    class Accounts
      def initialize(api_client)
        @api = api_client
        @logger = api_client.logger
      end

      # Get a specific account by currency code
      def get_account(currency_code)
        raise OrionX::ValidationError, "Currency code cannot be nil or empty" if currency_code.nil? || currency_code.empty?

        query = <<~GRAPHQL
          query sdk_getAccount($assetId: ID!) {
            wallet(code: $assetId) {
              _id
              currency {
                code
                units
              }
              balance
              availableBalance
              availableNetworks {
                code
              }
              balanceUSD
              balanceCLP
            }
          }
        GRAPHQL

        @logger.debug("Fetching account for currency: #{currency_code}")
        response = @api.call(query, { assetId: currency_code })
        
        result = response.dig("wallet")
        @logger.info("Account for #{currency_code} retrieved successfully") if result
        result
      end

      # Get all accounts for the user
      def get_accounts
        query = <<~GRAPHQL
          query sdk_getAccounts {
            me {
              wallets {
                _id
                currency {
                  code
                  units
                }
                balance
                availableBalance
                availableNetworks {
                  code
                }
                balanceUSD
                balanceCLP
              }
            }
          }
        GRAPHQL

        @logger.debug("Fetching all accounts")
        response = @api.call(query)
        
        result = response.dig("me", "wallets")
        @logger.info("All accounts retrieved: #{result&.length || 0} accounts") if result
        result
      end

      # Get account balance for a specific currency
      def get_balance(currency_code)
        account = get_account(currency_code)
        return nil unless account

        {
          currency: account.dig("currency", "code"),
          balance: account["balance"],
          available_balance: account["availableBalance"],
          balance_usd: account["balanceUSD"],
          balance_clp: account["balanceCLP"]
        }
      end

      # Get balances for all currencies
      def get_balances
        accounts = get_accounts
        return [] unless accounts

        accounts.map do |account|
          {
            currency: account.dig("currency", "code"),
            balance: account["balance"],
            available_balance: account["availableBalance"],
            balance_usd: account["balanceUSD"],
            balance_clp: account["balanceCLP"],
            wallet_id: account["_id"]
          }
        end
      end
    end
  end
end