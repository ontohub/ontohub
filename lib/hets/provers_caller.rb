module Hets
  class ProversCaller < ActionCaller
    CMD = 'provers'
    METHOD = :get
    COMMAND_LIST = %w(auto)

    OPTIONS = {format: 'json'}

    def call(iri)
      escaped_iri = Rack::Utils.escape_path(iri)
      arguments = [escaped_iri, *COMMAND_LIST]
      api_uri = build_api_uri(CMD, arguments, OPTIONS.merge(build_query_string))
      perform(api_uri, {}, METHOD)
    rescue UnfollowableResponseError => error
      handle_possible_hets_error(error)
    end
  end
end
