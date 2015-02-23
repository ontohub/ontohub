module Hets
  class ProveCaller < ActionCaller
    CMD = 'prove'
    METHOD = :post
    COMMAND_LIST = %w(auto)

    PROVE_OPTIONS = {format: 'json', include: 'true'}

    def call(iri, options = {})
      escaped_iri = Rack::Utils.escape_path(iri)
      arguments = [escaped_iri, *COMMAND_LIST]
      api_uri = build_api_uri(CMD, arguments, build_query_string)
      perform(api_uri, PROVE_OPTIONS.merge(options), METHOD)
    end
  end
end
