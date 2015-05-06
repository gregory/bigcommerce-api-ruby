require 'bigcommerce/request'
require 'bigcommerce/resource_actions'
require 'bigcommerce/subresource_actions'

module Bigcommerce
  class Resource < Hashie::Trash
    attr_reader :client

    include Hashie::Extensions::MethodAccess
    include Hashie::Extensions::IgnoreUndeclared

    def initialize(h, client=nil)
      @client = client
      super(h)
    end
  end
end
