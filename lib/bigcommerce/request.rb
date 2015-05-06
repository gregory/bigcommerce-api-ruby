require 'json'

module Bigcommerce
  class PathBuilder
    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    # This takes the @uri and inserts the keys to form a path.
    # To start we make sure that for nil/numeric values, we wrap those into an
    # array. We then scan the string for %d and %s to find the number of times
    # we possibly need to insert keys into the URI. Next, we check the size of
    # the keys array, if the keys size is less than the number of possible keys
    # in the URI, we will remove the trailing %d or %s, then remove the
    # trailing /. We then pass the keys into the uri to form the path.
    # ex. foo/%d/bar/%d => foo/1/bar/2
    def build(keys = [])
      keys = [] if keys.nil?
      keys = [keys] if keys.is_a? Numeric
      ids = uri.scan('%d').count + uri.scan('%s').count
      str = ids > keys.size ? uri.chomp('%d').chomp('%s').chomp('/') : uri
      (str % keys).chomp('/')
    end

    def to_s
      @uri
    end
  end

  class Request < Module
    def initialize(uri)
      @uri = uri
    end

    def included(base)
      base.extend ClassMethods
      path_builder = PathBuilder.new @uri
      base.define_singleton_method :path do
        path_builder
      end
    end

    module ClassMethods
      def get(path, params = {})
        objectify(client(params)) { |cli| cli.get(path, params) }
      end

      def delete(path, params={})
        client(params).tap { |cli| cli.delete(path, params) }
      end

      def post(path, params)
        objectify(client(params)) { |cli| cli.post(path, params) }
      end

      def put(path, params)
        objectify(client(params)) { |cli| cli.put(path, params) }
      end

      private

      def objectify(cli)
        json = Bigcommerce.jsonify yield(cli)
        json.is_a?(Array) ?  json.lazy.map { |obj| new(obj, cli) } : new(json, cli)
      end

      def client(params)
        params.delete(:client) || Bigcommerce.client(params.delete(:store_hash))
      end
    end
  end
end
