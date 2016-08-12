module Hets
  class ProveCaller < ActionCaller
    CMD = 'prove'
    METHOD = :post
    COMMAND_LIST = %w(auto)

    PROVE_OPTIONS = {format: 'json', include: 'true'}

    def call(iri)
      escaped_iri = Rack::Utils.escape_path(iri)
      arguments = [escaped_iri, *COMMAND_LIST]
      api_uri = build_api_uri(CMD, arguments, build_query_string)
      perform(api_uri, PROVE_OPTIONS.merge(hets_options.options), METHOD)
    rescue UnfollowableResponseError => error
      handle_possible_hets_error(error)
    end

    def build_query_string
      {}
    end

    def timeout
      # The HTTP timeout must be as long as Hets maximally takes.
      HetsInstance::FORCE_FREE_WAITING_PERIOD
    end
  end
end
