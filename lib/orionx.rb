require_relative "orionx/version"

module OrionX
  class Error < StandardError; end
  class APIError < Error; end
  class AuthenticationError < APIError; end
  class RateLimitError < APIError; end
  class ValidationError < Error; end
  class NetworkError < Error; end
end

require_relative "orionx/configuration"
require_relative "orionx/logger"
require_relative "orionx/client"
require_relative "orionx/api"
require_relative "orionx/endpoints/user"
require_relative "orionx/endpoints/orders"
require_relative "orionx/endpoints/accounts"
require_relative "orionx/endpoints/markets"
require_relative "orionx/endpoints/transactions"