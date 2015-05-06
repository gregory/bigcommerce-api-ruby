module Bigcommerce
  class Client
    attr_reader :api_limit, :config, :connection

    def initialize(config)
      @config     = config
      @connection = Bigcommerce.connection(config)
      @api_limit  = 0
    end

    def request(method, path, params = {})
      @connection.send(method, path.to_s, params).tap do |raw_response|
        @api_limit = raw_response.headers['X-BC-ApiLimit-Remaining']
      end.body
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def delete(path, params={})
      request(:delete, path, params)
    end

    def post(path, params)
      request(:post, path, params)
    end

    def put(path, params)
      request(:put, path, params)
    end
  end
end
