# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-10-03

### Added
- Initial release of OrionX Ruby SDK
- Complete GraphQL API coverage for OrionX exchange
- HMAC-SHA512 authentication implementation
- Comprehensive error handling with custom exception classes:
  - `OrionX::AuthenticationError`
  - `OrionX::ValidationError` 
  - `OrionX::RateLimitError`
  - `OrionX::NetworkError`
  - `OrionX::APIError`
- Debug mode with detailed HTTP request/response logging
- Automatic retry mechanism with exponential backoff
- Full endpoint coverage:
  - User operations (`user.me`, `user.user_id`)
  - Account management (`accounts.get_accounts`, `accounts.get_balance`)
  - Market data (`markets.get_markets`, `markets.get_orderbook`)
  - Order management (limit, market, stop-limit, stop-market orders)
  - Transaction operations (`transactions.get_transactions`, `transactions.send_crypto`)
- Configuration management with global and per-client settings
- Comprehensive test suite with RSpec
- Multiple usage examples:
  - Basic usage demonstration
  - Trading operations with safety comments
  - Real-time market data monitoring
  - Debug and error handling patterns
- Complete documentation with API reference
- Ruby gem packaging with proper dependencies
- MIT license

### Features
- Thread-safe configuration
- Configurable timeouts and retry policies
- Flexible logging system with custom logger support
- Input validation for all API methods
- Proper handling of OrionX currency units and precision
- Connection health checking with `ping` method
- Market statistics aggregation helpers
- Transaction history filtering and pagination

### Documentation
- Comprehensive README with quick start guide
- Detailed API reference for all methods
- Error handling best practices
- Security recommendations
- Development setup instructions
- Contributing guidelines
- Multiple working code examples

### Dependencies
- `faraday` ~> 2.0 for HTTP client
- `faraday-net_http` ~> 3.0 for HTTP adapter  
- `logger` ~> 1.5 for logging functionality
- Development dependencies for testing and code quality

[1.0.0]: https://github.com/orionx-dev/orionx-sdk-ruby/releases/tag/v1.0.0