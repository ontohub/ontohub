module Hets
  class ProveCaller < ActionCaller
    CMD = 'prove'
    METHOD = :post
    COMMAND_LIST = %w(auto full-theories full-signatures)

    PROVE_OPTIONS = {format: 'json', include: 'false'}

    def call(iri)
      escaped_iri = Rack::Utils.escape_path(iri)
      arguments = [escaped_iri, *COMMAND_LIST]
      api_uri = build_api_uri(CMD, arguments, build_query_string)
      perform(api_uri, PROVE_OPTIONS.merge(hets_options.options), METHOD)
    rescue UnfollowableResponseError => error
      handle_possible_hets_error(error)
    end

    def build_query_string
      if hets_options.options[:'input-type']
        {:'input-type' => hets_options.options[:'input-type']}
      else
        {}
      end.merge('hets-libdirs' => libdirs)
    end
  end
end
