module Hets
  class ParseCaller < ActionCaller
    # Server-Instances should be started with the following
    # arguments: `hets +RTS -K1G -RTS -a none`
    MODE_ARGUMENTS = {
      fast_run: %w(just-structured),
      default: %w(full-signatures full-theories)
    }

    CMD = 'dg'
    METHOD = :get

    def call(iri, with_mode: :default)
      escaped_iri = Rack::Utils.escape_path(iri)
      arguments = [escaped_iri, *MODE_ARGUMENTS[with_mode]]
      api_uri = build_api_uri(CMD, arguments, build_query_string)
      perform(api_uri, {}, METHOD)
    end
  end
end
