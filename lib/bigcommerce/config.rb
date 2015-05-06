require 'hashie'
module Bigcommerce
  class Config < Hashie::Mash
    DEFAULTS = {
      base_url: 'https://api.bigcommerce.com'
    }

    def for_store(store_hash)
      Config.new self.merge(store_hash: store_hash)
    end

    def store_hash
      self[:store_hash] || fail(ArgumentError, 'Please setup a store_hash first')
    end

    def api_url
      return self.url if self.auth == 'legacy'

      base = ENV['BC_API_ENDPOINT'].nil? ? DEFAULTS[:base_url] : ENV['BC_API_ENDPOINT']
      "#{base}/stores/#{self.store_hash}/v2"
    end
  end
end
