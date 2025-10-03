#!/usr/bin/env ruby

# Basic usage example of the OrionX Ruby SDK

require_relative "../lib/orionx"

# Configure the SDK with your credentials
OrionX.configure do |config|
  config.api_key = ENV["ORIONX_API_KEY"] || "your-api-key"
  config.api_secret = ENV["ORIONX_API_SECRET"] || "your-api-secret"
  config.debug = true  # Enable debug logging
end

# Create a client instance
client = OrionX::Client.new

puts "=== OrionX Ruby SDK Basic Usage Example ==="

begin
  # Test connection
  puts "\n1. Testing connection..."
  ping_result = client.ping
  puts "Connection status: #{ping_result[:status]}"
  puts "Message: #{ping_result[:message]}"

  # Get user information
  puts "\n2. Getting user information..."
  user_info = client.me
  puts "User ID: #{user_info['_id']}"
  puts "Email: #{user_info['email']}"
  puts "Name: #{user_info['name']}"

  # Get account balances
  puts "\n3. Getting account balances..."
  balances = client.accounts.get_balances
  balances.each do |balance|
    puts "#{balance[:currency]}: #{balance[:balance]} (Available: #{balance[:available_balance]})"
  end

  # Get available markets
  puts "\n4. Getting available markets..."
  markets = client.markets.get_markets
  puts "Available markets: #{markets.length}"
  markets.first(5).each do |market|
    puts "- #{market['code']}: #{market['name']} (Last: #{market.dig('lastTrade', 'price')})"
  end

  # Get BTC/CLP market orderbook
  puts "\n5. Getting BTC/CLP orderbook..."
  orderbook = client.markets.get_orderbook("BTCCLP", limit: 5)
  if orderbook
    puts "Spread: #{orderbook['spread']}"
    puts "Mid price: #{orderbook['mid']}"
    puts "Best buy orders:"
    orderbook['buy'].first(3).each do |order|
      puts "  Price: #{order['limitPrice']}, Amount: #{order['amount']}"
    end
    puts "Best sell orders:"
    orderbook['sell'].first(3).each do |order|
      puts "  Price: #{order['limitPrice']}, Amount: #{order['amount']}"
    end
  end

  # Get recent orders
  puts "\n6. Getting recent orders..."
  orders = client.orders.get_orders(limit: 5)
  if orders && orders['items']
    puts "Recent orders: #{orders['items'].length}"
    orders['items'].each do |order|
      puts "- #{order['type']} order: #{order['amount']} at #{order['limitPrice']} (#{order['status']})"
    end
  else
    puts "No recent orders found"
  end

  puts "\n=== Example completed successfully! ==="

rescue OrionX::AuthenticationError => e
  puts "❌ Authentication Error: #{e.message}"
  puts "Please check your API credentials"
rescue OrionX::APIError => e
  puts "❌ API Error: #{e.message}"
rescue OrionX::NetworkError => e
  puts "❌ Network Error: #{e.message}"
rescue OrionX::Error => e
  puts "❌ SDK Error: #{e.message}"
rescue => e
  puts "❌ Unexpected Error: #{e.message}"
  puts e.backtrace.first(5)
end