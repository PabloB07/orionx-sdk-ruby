module OrionX
  module Endpoints
    class User
      def initialize(api_client)
        @api = api_client
        @logger = api_client.logger
      end

      # Get current user information
      def me
        query = <<~GRAPHQL
          query sdk_getMe {
            me {
              _id
              email
              name
              profile {
                fullName
                phone
                kycVerified
                birthdate
                countryCode
                occupation
                address
              }
            }
          }
        GRAPHQL

        @logger.debug("Fetching user profile")
        response = @api.call(query)
        
        result = response.dig("me")
        @logger.info("User profile retrieved successfully") if result
        result
      end

      # Get user ID only
      def user_id
        query = <<~GRAPHQL
          query sdk_getUserId {
            me {
              _id
            }
          }
        GRAPHQL

        @logger.debug("Fetching user ID")
        response = @api.call(query)
        response.dig("me", "_id")
      end
    end
  end
end