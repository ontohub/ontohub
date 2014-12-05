module Hets
  class ProveCaller < ActionCaller
    CMD = 'prove'
    METHOD = :post

    PROVE_OPTIONS = {format: 'json', include: 'true'}

    def call(iri)
      escaped_iri = Rack::Utils.escape_path(iri)
      arguments = [escaped_iri]
      api_uri = build_api_uri(CMD, arguments, build_query_string)
      perform(api_uri, PROVE_OPTIONS, METHOD)
    end
  end
end
