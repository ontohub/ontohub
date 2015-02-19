module Hets
  class ActionCaller < Caller
    attr_accessor :url_catalog, :access_token

    def initialize(hets_instance, options = nil)
      if options
        self.url_catalog = options.url_catalog
        self.access_token = options.access_token
      end
      msg = "<#{hets_instance}> not up."
      raise Hets::InactiveInstanceError, msg unless hets_instance.up?
      super(hets_instance)
    end

    def build_query_string
      query_hash = {}
      query_hash[:"url-catalog"] = url_catalog.join(',') if url_catalog.present?
      query_hash[:"access-token"] = access_token if access_token.present?
      query_hash
    end
  end
end
