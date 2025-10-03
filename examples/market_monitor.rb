#!/usr/bin/env ruby

# Market data monitoring example using the OrionX Ruby SDK

require_relative "../lib/orionx"

# Configure the SDK
OrionX.configure do |config|
  config.api_key = ENV["ORIONX_API_KEY"] || "your-api-key"
  config.api_secret = ENV["ORIONX_API_SECRET"] || "your-api-secret"
  config.debug = false  # Less verbose for monitoring
end

client = OrionX::Client.new

puts "=== OrionX Market Data Monitor ==="

# Markets to monitor
MARKETS_TO_MONITOR = ["BTCCLP", "ETHCLP", "USDTCLP"]

def format_price(price)
  return "N/A" if price.nil?
  # Format large numbers with commas
  price.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def format_percentage(current, previous)
  return "N/A" if current.nil? || previous.nil? || previous == 0
  change = ((current - previous) / previous.to_f) * 100
  sign = change >= 0 ? "+" : ""
  "#{sign}#{change.round(2)}%"
end

begin
  # Store previous prices for change calculation
  previous_prices = {}

  puts "Starting market monitoring... (Press Ctrl+C to stop)"
  puts "Monitoring markets: #{MARKETS_TO_MONITOR.join(', ')}"
  puts

  loop do
    timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    puts "=" * 80
    puts "Market Update - #{timestamp}"
    puts "=" * 80

    MARKETS_TO_MONITOR.each do |market_code|
      begin
        # Get market statistics
        stats = client.markets.get_market_stats(market_code)
        
        if stats
          current_price = stats[:last_price]
          previous_price = previous_prices[market_code]
          change = format_percentage(current_price, previous_price)

          puts "#{market_code.ljust(10)} | Price: #{format_price(current_price).rjust(12)} | Change: #{change.rjust(8)} | Spread: #{format_price(stats[:spread]).rjust(10)}"
          puts "#{' ' * 10} | Bid: #{format_price(stats[:best_bid]).rjust(14)} | Ask: #{format_price(stats[:best_ask]).rjust(12)} | Mid: #{format_price(stats[:mid_price]).rjust(13)}"

          # Store current price for next iteration
          previous_prices[market_code] = current_price
        else
          puts "#{market_code.ljust(10)} | Error fetching data"
        end

      rescue => e
        puts "#{market_code.ljust(10)} | Error: #{e.message}"
      end

      puts "-" * 80
    end

    # Get top orderbook entries for BTC/CLP
    begin
      puts "\nBTC/CLP Orderbook (Top 3):"
      orderbook = client.markets.get_orderbook("BTCCLP", limit: 3)
      
      if orderbook
        puts "SELL ORDERS (ASK):"
        orderbook['sell'].each_with_index do |order, i|
          puts "  #{i+1}. #{format_price(order['amount']).rjust(10)} BTC @ #{format_price(order['limitPrice']).rjust(12)} CLP"
        end

        puts "BUY ORDERS (BID):"
        orderbook['buy'].each_with_index do |order, i|
          puts "  #{i+1}. #{format_price(order['amount']).rjust(10)} BTC @ #{format_price(order['limitPrice']).rjust(12)} CLP"
        end
      end
    rescue => e
      puts "Error fetching orderbook: #{e.message}"
    end

    puts "\nNext update in 30 seconds..."
    sleep(30)
  end

rescue Interrupt
  puts "\n\n=== Market monitoring stopped ==="
  puts "Final prices:"
  previous_prices.each do |market, price|
    puts "#{market}: #{format_price(price)}"
  end

rescue OrionX::AuthenticationError => e
  puts "❌ Authentication Error: #{e.message}"
  puts "Please check your API credentials"
rescue OrionX::APIError => e
  puts "❌ API Error: #{e.message}"
rescue OrionX::NetworkError => e
  puts "❌ Network Error: #{e.message}"
  puts "Please check your internet connection"
rescue => e
  puts "❌ Unexpected Error: #{e.message}"
  puts e.backtrace.first(3)
end