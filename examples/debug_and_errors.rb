#!/usr/bin/env ruby

# Debug and error handling demonstration for the OrionX Ruby SDK

require_relative "../lib/orionx"

puts "=== OrionX Debug and Error Handling Demo ==="

# Example 1: Authentication Error
puts "\n1. Testing Authentication Error..."
OrionX.configure do |config|
  config.api_key = "invalid_key"
  config.api_secret = "invalid_secret"
  config.debug = true
end

begin
  client = OrionX::Client.new
  client.me
rescue OrionX::AuthenticationError => e
  puts "✅ Caught expected authentication error: #{e.message}"
end

# Example 2: Validation Errors
puts "\n2. Testing Validation Errors..."
OrionX.configure do |config|
  config.api_key = ENV["ORIONX_API_KEY"] || "your-api-key"
  config.api_secret = ENV["ORIONX_API_SECRET"] || "your-api-secret"
  config.debug = true
end

client = OrionX::Client.new

# Test various validation scenarios
validation_tests = [
  {
    name: "Empty market code",
    action: -> { client.orders.get_order("") }
  },
  {
    name: "Nil order ID",
    action: -> { client.orders.get_order(nil) }
  },
  {
    name: "Invalid amount",
    action: -> { 
      client.orders.place_limit_order(
        market_code: "BTCCLP",
        amount: -100,
        limit_price: 50000000,
        sell: false
      )
    }
  },
  {
    name: "Missing limit price",
    action: -> {
      client.orders.place_limit_order(
        market_code: "BTCCLP",
        amount: 1000,
        limit_price: nil,
        sell: false
      )
    }
  }
]

validation_tests.each do |test|
  begin
    test[:action].call
    puts "❌ Expected validation error for: #{test[:name]}"
  rescue OrionX::ValidationError => e
    puts "✅ Caught expected validation error (#{test[:name]}): #{e.message}"
  rescue => e
    puts "❓ Unexpected error for #{test[:name]}: #{e.class} - #{e.message}"
  end
end

# Example 3: Network Error Simulation
puts "\n3. Testing Network Error Handling..."
begin
  # Temporarily change endpoint to invalid URL
  OrionX.configure do |config|
    config.api_endpoint = "https://invalid-endpoint-12345.com/graphql"
    config.timeout = 5  # Short timeout for quick demo
  end

  client = OrionX::Client.new
  client.ping
rescue OrionX::NetworkError => e
  puts "✅ Caught expected network error: #{e.message}"
rescue => e
  puts "✅ Network-related error: #{e.class} - #{e.message}"
end

# Example 4: Debug Logging Demo
puts "\n4. Debug Logging Demo..."
OrionX.configure do |config|
  config.api_key = ENV["ORIONX_API_KEY"] || "your-api-key"
  config.api_secret = ENV["ORIONX_API_SECRET"] || "your-api-secret"
  config.api_endpoint = "https://api2.orionx.io/graphql"
  config.debug = true  # Enable detailed logging
  config.logger.level = Logger::DEBUG
end

puts "With debug enabled, you should see detailed HTTP requests and responses:"

begin
  client = OrionX::Client.new
  
  puts "\nFetching user info with debug logging..."
  user_info = client.me
  puts "✅ User fetched successfully: #{user_info['name']}"

  puts "\nFetching market data with debug logging..."
  market = client.markets.get_market("BTCCLP")
  puts "✅ Market data fetched: #{market['name']}"

rescue => e
  puts "Error during debug demo: #{e.message}"
end

# Example 5: Error Recovery and Retry Demo
puts "\n5. Error Recovery Demo..."
OrionX.configure do |config|
  config.api_key = ENV["ORIONX_API_KEY"] || "your-api-key"
  config.api_secret = ENV["ORIONX_API_SECRET"] || "your-api-secret"
  config.api_endpoint = "https://api2.orionx.io/graphql"
  config.debug = false  # Less verbose for this demo
  config.retries = 2    # Enable retries
end

puts "SDK will automatically retry failed requests up to #{OrionX.configuration.retries} times"

begin
  client = OrionX::Client.new
  
  # This should work normally
  result = client.ping
  puts "✅ Connection test: #{result[:status]}"

rescue => e
  puts "❌ Connection failed even with retries: #{e.message}"
end

# Example 6: Custom Error Handling
puts "\n6. Custom Error Handling Patterns..."

def safe_api_call(description)
  yield
rescue OrionX::AuthenticationError => e
  puts "❌ Auth issue (#{description}): Please check your API credentials"
  return { error: "authentication", message: e.message }
rescue OrionX::ValidationError => e
  puts "❌ Validation issue (#{description}): #{e.message}"
  return { error: "validation", message: e.message }
rescue OrionX::RateLimitError => e
  puts "⚠️  Rate limited (#{description}): #{e.message}"
  puts "Suggestion: Wait before retrying"
  return { error: "rate_limit", message: e.message }
rescue OrionX::NetworkError => e
  puts "🌐 Network issue (#{description}): #{e.message}"
  puts "Suggestion: Check internet connection"
  return { error: "network", message: e.message }
rescue OrionX::APIError => e
  puts "🔧 API issue (#{description}): #{e.message}"
  return { error: "api", message: e.message }
rescue OrionX::Error => e
  puts "❓ SDK error (#{description}): #{e.message}"
  return { error: "sdk", message: e.message }
rescue => e
  puts "💥 Unexpected error (#{description}): #{e.class} - #{e.message}"
  return { error: "unexpected", message: e.message }
end

# Test the safe wrapper
client = OrionX::Client.new

results = [
  safe_api_call("User info") { client.me },
  safe_api_call("Invalid order") { client.orders.get_order("") },
  safe_api_call("Market data") { client.markets.get_market("BTCCLP") }
]

puts "\nSafe API call results:"
results.each_with_index do |result, i|
  if result.is_a?(Hash) && result[:error]
    puts "#{i+1}. Error: #{result[:error]} - #{result[:message]}"
  else
    puts "#{i+1}. Success: Operation completed"
  end
end

puts "\n=== Debug and Error Handling Demo Complete ==="
puts "\nKey takeaways:"
puts "1. Always wrap API calls in appropriate exception handlers"
puts "2. Use debug mode during development"
puts "3. Implement proper error recovery strategies"
puts "4. Validate inputs before making API calls"
puts "5. Handle different error types appropriately"