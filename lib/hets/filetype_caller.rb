module Hets
  class FiletypeCaller < Caller
    CMD = 'filetype'
    METHOD = :get

    def call(iri)
      escaped_iri = Rack::Utils.escape_path(iri)
      perform(build_api_uri(CMD, escaped_iri), METHOD)
    end

    def http_result_options
      STRING_RESPONSE
    end
  end
end
