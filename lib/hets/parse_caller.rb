module Hets
  class ParseCaller < Caller

    # Server-Instances should be started with the following
    # arguments: `hets +RTS -K1G -RTS -a none`
    MODE_ARGUMENTS = {
      fast_run: %w(just-structured),
      default: %w(full-signatures full-theories)
    }

    CMD = 'dg'
    METHOD = :get

    attr_accessor :url_catalog

    def initialize(hets_instance, url_catalog=[])
      self.url_catalog = url_catalog
      msg = "<#{hets_instance}> not up."
      raise Hets::InactiveInstanceError, msg unless hets_instance.up?
      super(hets_instance)
    end

    def call(iri, with_mode: :default)
      escaped_iri = Rack::Utils.escape_path(iri)
      arguments = [escaped_iri, *MODE_ARGUMENTS[with_mode]]
      api_uri = build_api_uri(CMD, arguments, build_query_string)
      perform(api_uri, METHOD)
    end

    def build_query_string
      query_hash = {}
      query_hash[:"url-catalog"] = url_catalog.join(',') if url_catalog.present?
    end

  end
end
