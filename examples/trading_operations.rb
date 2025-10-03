#!/usr/bin/env ruby

# Trading operations example using the OrionX Ruby SDK

require_relative "../lib/orionx"

# Configure the SDK
OrionX.configure do |config|
  config.api_key = ENV["ORIONX_API_KEY"] || "your-api-key"
  config.api_secret = ENV["ORIONX_API_SECRET"] || "your-api-secret"
  config.debug = true
end

client = OrionX::Client.new

puts "=== OrionX Trading Operations Example ==="

begin
  # Check account balances first
  puts "\n1. Current balances:"
  balances = client.accounts.get_balances
  btc_balance = balances.find { |b| b[:currency] == "BTC" }
  clp_balance = balances.find { |b| b[:currency] == "CLP" }

  puts "BTC: #{btc_balance&.dig(:balance) || 0}"
  puts "CLP: #{clp_balance&.dig(:balance) || 0}"

  # Get current market data
  puts "\n2. BTC/CLP Market Analysis:"
  market_stats = client.markets.get_market_stats("BTCCLP")
  if market_stats
    puts "Last price: #{market_stats[:last_price]}"
    puts "Spread: #{market_stats[:spread]}"
    puts "Best bid: #{market_stats[:best_bid]}"
    puts "Best ask: #{market_stats[:best_ask]}"
  end

  # Example 1: Place a limit buy order (DEMO - using small amounts)
  puts "\n3. Placing a limit buy order (DEMO)..."
  
  # WARNING: This is a real order! Comment out if just testing
  # limit_order = client.orders.place_limit_order(
  #   market_code: "BTCCLP",
  #   amount: 1000,  # Very small amount for demo
  #   limit_price: (market_stats[:best_bid] - 1000000).to_i,  # Below market
  #   sell: false,   # Buy order
  #   client_id: "ruby-sdk-demo-#{Time.now.to_i}"
  # )
  # 
  # if limit_order
  #   puts "✅ Limit order placed: #{limit_order['_id']}"
  #   puts "Status: #{limit_order['status']}"
  #   order_id_to_cancel = limit_order['_id']
  # end

  # Example 2: Place a stop-limit order
  puts "\n4. Placing a stop-limit order (DEMO)..."
  
  # WARNING: This is a real order! Comment out if just testing
  # stop_order = client.orders.place_stop_limit_order(
  #   market_code: "BTCCLP",
  #   stop_price_up: (market_stats[:last_price] + 2000000).to_i,  # Trigger above current
  #   stop_price_down: (market_stats[:last_price] - 2000000).to_i, # Trigger below current
  #   amount: 1000,
  #   limit_price: market_stats[:last_price].to_i,
  #   sell: true,  # Sell order
  #   client_id: "ruby-sdk-stop-demo-#{Time.now.to_i}"
  # )
  # 
  # if stop_order
  #   puts "✅ Stop-limit order placed: #{stop_order['_id']}"
  #   puts "Status: #{stop_order['status']}"
  # end

  # Example 3: Get and display current orders
  puts "\n5. Current open orders:"
  open_orders = client.orders.get_orders(onlyOpen: true, limit: 10)
  if open_orders && open_orders['items'] && !open_orders['items'].empty?
    open_orders['items'].each do |order|
      puts "- Order #{order['_id']}: #{order['type']} #{order['amount']} at #{order['limitPrice']} (#{order['status']})"
    end
  else
    puts "No open orders"
  end

  # Example 4: Cancel an order (if we placed one)
  # if defined?(order_id_to_cancel)
  #   puts "\n6. Cancelling demo order..."
  #   cancelled = client.orders.cancel_order(order_id_to_cancel)
  #   if cancelled
  #     puts "✅ Order cancelled: #{cancelled['_id']}"
  #     puts "Status: #{cancelled['status']}"
  #   end
  # end

  # Example 5: Get recent transaction history
  puts "\n7. Recent BTC transactions:"
  btc_history = client.transactions.get_history("BTC", limit: 5)
  if btc_history && btc_history['items']
    btc_history['items'].each do |tx|
      puts "- #{tx['type']}: #{tx['amount']} BTC (#{Time.at(tx['date'] / 1000)})"
    end
  else
    puts "No recent BTC transactions"
  end

  puts "\n=== Trading example completed! ==="
  puts "\nNote: Actual trading operations are commented out for safety."
  puts "Uncomment the order placement code to execute real trades."

rescue OrionX::ValidationError => e
  puts "❌ Validation Error: #{e.message}"
rescue OrionX::AuthenticationError => e
  puts "❌ Authentication Error: #{e.message}"
rescue OrionX::APIError => e
  puts "❌ API Error: #{e.message}"
rescue => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(3)
end