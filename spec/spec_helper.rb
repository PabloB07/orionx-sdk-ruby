require "rspec"
require "webmock/rspec"
require "simplecov"

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"
end

require_relative "../lib/orionx"

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.verify_partial_doubles = true
  end

  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true

  config.before(:each) do
    # Reset configuration before each test
    OrionX.instance_variable_set(:@configuration, nil)
  end
end

# Test helpers
def configure_orionx(debug: false)
  OrionX.configure do |config|
    config.api_key = "test_api_key"
    config.api_secret = "test_api_secret"
    config.api_endpoint = "https://api.test.orionx.com/graphql"
    config.debug = debug
  end
end

def stub_graphql_request(query_match, response_body = {}, status: 200)
  stub_request(:post, "https://api.test.orionx.com/graphql")
    .with(
      body: hash_including("query" => a_string_matching(query_match)),
      headers: {
        "Content-Type" => "application/json",
        "X-ORIONX-APIKEY" => "test_api_key",
        "X-ORIONX-TIMESTAMP" => /.+/,
        "X-ORIONX-SIGNATURE" => /.+/
      }
    )
    .to_return(
      status: status,
      body: { data: response_body }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
end