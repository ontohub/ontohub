module Hets
  class ActionCaller < Caller
    attr_accessor :url_catalog

    def initialize(hets_instance, url_catalog = [])
      self.url_catalog = url_catalog
      msg = "<#{hets_instance}> not up."
      raise Hets::InactiveInstanceError, msg unless hets_instance.try(:up?)
      super(hets_instance)
    end

    def build_query_string
      query_hash = {}
      query_hash[:"url-catalog"] = url_catalog.join(',') if url_catalog.present?
      query_hash
    end

    def handle_possible_hets_error(error)
      HetsErrorProcess.new(error).handle
    rescue Hets::NotAHetsError
      raise error
    end
  end
end
