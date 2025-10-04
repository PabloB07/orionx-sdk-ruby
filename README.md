# Unofficial OrionX Ruby SDK

The unofficial OrionX SDK for Ruby - A comprehensive Ruby library for interacting with the OrionX cryptocurrency exchange API.

[![Gem Version](https://badge.fury.io/rb/orionx-sdk-ruby.svg)](https://badge.fury.io/rb/orionx-sdk-ruby)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🔐 **Secure Authentication** - HMAC-SHA512 signature authentication
- 🐛 **Debug Mode** - Comprehensive logging and debugging capabilities  
- 🛡️ **Error Handling** - Robust error handling with custom exception classes
- 🔄 **Auto Retry** - Automatic retry mechanism for failed requests
- 📈 **Trading Operations** - Full support for limit, market, and stop orders
- 💰 **Account Management** - Balance inquiries and account information
- 📊 **Market Data** - Real-time market data and orderbook information
- 💸 **Transactions** - Transaction history and cryptocurrency transfers
- 🧪 **Comprehensive Tests** - Well-tested with RSpec
- 📚 **Rich Examples** - Multiple usage examples included

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'orionx-sdk-ruby'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install orionx-sdk-ruby
```

## Quick Start

### 1. Get Your API Credentials

First, you'll need to get your API credentials from OrionX:

1. Log in to your [OrionX account](https://orionx.com)
2. Go to API settings
3. Generate your API Key and Secret
4. Follow [this tutorial](http://docs.orionx.com/docs/getStarted.html) for detailed instructions

### 2. Configuration

Configure the SDK with your credentials:

```ruby
require 'orionx'

# Global configuration (recommended)
OrionX.configure do |config|
  config.api_key = 'your-api-key'
  config.api_secret = 'your-api-secret'  
  config.debug = true  # Enable debug logging (optional)
end

# Create client instance
client = OrionX::Client.new
```

Or configure per client instance:

```ruby
client = OrionX::Client.new(
  api_key: 'your-api-key',
  api_secret: 'your-api-secret',
  debug: true
)
```

### 3. Basic Usage

```ruby
# Test connection
ping = client.ping
puts ping  # => { status: "ok", message: "Connection successful" }

# Get user information  
user = client.me
puts user['name']  # => "Your Name"

# Get account balances
balances = client.accounts.get_balances
balances.each do |balance|
  puts "#{balance[:currency]}: #{balance[:balance]}"
end

# Get market data
market = client.markets.get_market('BTCCLP')
puts "BTC/CLP Last Price: #{market.dig('lastTrade', 'price')}"
```

## API Reference

### User Operations

```ruby
# Get current user information
user = client.user.me
# Returns: { "_id" => "...", "email" => "...", "name" => "...", ... }

# Get user ID only
user_id = client.user.user_id
# Returns: "user_id_string"
```

### Account Management

```ruby
# Get all account balances
balances = client.accounts.get_balances
# Returns array of balance objects

# Get specific currency account
btc_account = client.accounts.get_account('BTC')
# Returns: { "_id" => "...", "currency" => {...}, "balance" => 0, ... }

# Get balance for specific currency
btc_balance = client.accounts.get_balance('BTC')
# Returns: { currency: "BTC", balance: 0, available_balance: 0, ... }
```

### Market Data

```ruby
# Get all available markets
markets = client.markets.get_markets
# Returns array of market objects

# Get specific market information
btc_market = client.markets.get_market('BTCCLP')
# Returns: { "code" => "BTCCLP", "name" => "BTC/CLP", ... }

# Get market orderbook
orderbook = client.markets.get_orderbook('BTCCLP', limit: 10)
# Returns: { "buy" => [...], "sell" => [...], "spread" => 0, "mid" => 0 }

# Get market statistics (convenience method)
stats = client.markets.get_market_stats('BTCCLP')
# Returns: { code: "BTCCLP", last_price: 0, spread: 0, ... }
```

### Order Management

```ruby
# Get user's orders
orders = client.orders.get_orders(onlyOpen: true, limit: 10)

# Get specific order
order = client.orders.get_order('order_id')

# Place limit order
limit_order = client.orders.place_limit_order(
  market_code: 'BTCCLP',
  amount: 10000,          # Amount in base currency units
  limit_price: 50000000,  # Price in quote currency units  
  sell: false             # true for sell, false for buy
)

# Place market order
market_order = client.orders.place_market_order(
  market_code: 'BTCCLP',
  amount: 10000,
  sell: false
)

# Place stop-limit order
stop_order = client.orders.place_stop_limit_order(
  market_code: 'BTCCLP',
  stop_price_up: 52000000,    # Upper trigger price
  stop_price_down: 48000000,  # Lower trigger price  
  amount: 10000,
  limit_price: 50000000,
  sell: true
)

# Cancel order
cancelled = client.orders.cancel_order('order_id')
```

### Transaction Operations

```ruby
# Get transaction history
transactions = client.transactions.get_transactions(
  limit: 20,
  page: 1,
  types: ['trade-in', 'trade-out']
)

# Get specific transaction
transaction = client.transactions.get_transaction('transaction_id')

# Get transaction history for specific currency
btc_history = client.transactions.get_history('BTC', limit: 10)

# Send cryptocurrency (requires additional setup)
send_result = client.transactions.send_crypto(
  wallet_id: 'wallet_id',
  network: 'BTC', 
  amount: 100000,
  contact_id: 'contact_id'  # Optional
)
```

## Error Handling

The SDK provides comprehensive error handling with specific exception types:

```ruby
begin
  result = client.me
rescue OrionX::AuthenticationError => e
  puts "Invalid API credentials: #{e.message}"
rescue OrionX::ValidationError => e
  puts "Invalid parameters: #{e.message}"
rescue OrionX::RateLimitError => e
  puts "Rate limit exceeded: #{e.message}"
rescue OrionX::NetworkError => e
  puts "Network error: #{e.message}"  
rescue OrionX::APIError => e
  puts "API error: #{e.message}"
rescue OrionX::Error => e
  puts "SDK error: #{e.message}"
end
```

### Exception Types

- `OrionX::AuthenticationError` - Invalid API credentials
- `OrionX::ValidationError` - Invalid parameters or input validation failed
- `OrionX::RateLimitError` - API rate limit exceeded
- `OrionX::NetworkError` - Network connectivity issues
- `OrionX::APIError` - General API errors
- `OrionX::Error` - Base SDK error class

## Debug Mode

Enable debug mode to see detailed HTTP requests and responses:

```ruby
# Global configuration
OrionX.configure do |config|
  config.debug = true
end

# Or per client
client.debug = true

# The debug output includes:
# - HTTP request headers and body
# - GraphQL queries and variables  
# - HTTP response status and body
# - Request/response timing
# - Signature generation details
```

## Configuration Options

```ruby
OrionX.configure do |config|
  config.api_key = 'your-api-key'         # Required
  config.api_secret = 'your-api-secret'   # Required  
  config.api_endpoint = 'custom-endpoint' # Optional, defaults to OrionX API
  config.debug = false                    # Optional, enables debug logging
  config.timeout = 30                     # Optional, request timeout in seconds
  config.retries = 3                      # Optional, number of retries for failed requests
  config.logger = custom_logger           # Optional, custom logger instance
end
```

## Examples

The SDK includes several comprehensive examples:

### Basic Usage Example
```bash
ruby examples/basic_usage.rb
```
Demonstrates connection testing, user information, balances, and market data.

### Trading Operations Example  
```bash
ruby examples/trading_operations.rb
```
Shows how to place different order types, manage orders, and handle trading operations.

### Market Data Monitor
```bash  
ruby examples/market_monitor.rb
```
Real-time market monitoring with price updates and orderbook data.

### Debug and Error Handling
```bash
ruby examples/debug_and_errors.rb  
```
Comprehensive demonstration of debug features and error handling patterns.

## Development

### Setup

```bash
git clone https://github.com/PabloB07/orionx-sdk-ruby.git
cd orionx-sdk-ruby
bundle install
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec

# Run specific test file
bundle exec rspec spec/client_spec.rb
```

### Code Quality

```bash  
# Run RuboCop linter
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -A
```

## API Reference Documentation

For detailed API documentation, visit:
- [OrionX API Documentation](http://docs.orionx.com/)
- [GraphQL Schema Reference](https://api2.orionx.com/graphql)

## Important Notes

### Currency Units

OrionX uses specific units for different currencies:
- **BTC**: 8 decimal places (Satoshis) - 1 BTC = 100,000,000 units
- **ETH**: 18 decimal places (Wei) - 1 ETH = 1,000,000,000,000,000,000 units  
- **CLP**: 0 decimal places - 1 CLP = 1 unit
- **USD**: 2 decimal places - 1 USD = 100 units

### Rate Limits

The OrionX API has rate limits. The SDK automatically handles retries with exponential backoff for rate-limited requests.

### Security

- Never commit your API credentials to version control
- Use environment variables for credentials in production
- Enable debug mode only in development environments
- Regularly rotate your API keys

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`bundle exec rspec`)
5. Run RuboCop (`bundle exec rubocop`)
6. Commit your changes (`git commit -am 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)  
8. Open a Pull Request

## Changelog

### Version 1.0.0
- Initial release
- Complete API coverage for OrionX GraphQL API
- Comprehensive error handling and debug capabilities
- Full test suite with RSpec
- Multiple usage examples
- Detailed documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/PabloB07/orionx-sdk-ruby/issues)
- **Documentation**: [OrionX API Docs](http://docs.orionx.com/)
- **Email**: [support@orionx.com](mailto:support@orionx.com)

## Acknowledgments

- Inspired by the [official OrionX JavaScript SDK](https://github.com/orionx-dev/orionx-sdk-js)
- Built with Ruby community best practices
- Thanks to the OrionX development team for API support

---

Made with ❤️ by PabloB07
