require 'hashie'
require 'faraday_middleware'
require 'bigcommerce/version'
require 'bigcommerce/config'
require 'bigcommerce/client'
require 'bigcommerce/middleware/auth'
require 'bigcommerce/middleware/http_exception'
require 'bigcommerce/resources/resource'

module Bigcommerce
  resources = File.join(File.dirname(__FILE__), 'bigcommerce', 'resources', '**', '*.rb')
  Dir.glob(resources, &method(:require))

  HEADERS = {
    'accept' => 'application/json',
    'content-type' => 'application/json',
    'user-agent' => 'bigcommerce-api-ruby'
  }

  class << self
    def configure
      @config = Config.new.tap { |h| yield(h) }
    end

    def config
      @config || fail(ArgumentError, 'Please use Bigcommerce.configure {} first')
    end
  end

  def self.client(store_hash=nil)
    store_hash.nil? ? Client.new(config) : Client.new(config.for_store(store_hash))
  end

  def self.connection(options)
    ssl_options = options.ssl if options.auth == 'legacy'
    Faraday.new(url: options.api_url, ssl: ssl_options) do |conn|
      conn.request :json
      conn.headers = HEADERS
      if options.auth == 'legacy'
        conn.use Faraday::Request::BasicAuthentication, options.username, options.api_key
      else
        conn.use Bigcommerce::Middleware::Auth, options
      end
      conn.use Bigcommerce::Middleware::HttpException
      conn.adapter Faraday.default_adapter
    end
  end

  def self.jsonify(input)
    input.empty? ? [] : JSON.parse(input, symbolize_names: true)
  rescue => e
    puts "[RESPONSE PARSING ERROR]: #{e.message}"
    []
  end

end
