require_relative 'base_generator.rb'

module FixturesGeneration
  class DirectHetsGenerator < BaseGenerator
    HETS_API_OPTIONS = '/auto'
    HETS_BASE_IRI = 'http://localhost:8000'

    def call
      if outdated_cassettes.any?
        with_running_hets { super }
      end
    end

    protected

    def call_hets(file, command,
                  method: :get,
                  hets_api_options: HETS_API_OPTIONS,
                  query_string: '',
                  header: {},
                  data: {})
      puts "Calling hets/#{command} on #{file.inspect}"
      escaped_iri = Rack::Utils.escape_path("file://#{absolute_filepath(file)}")
      hets_iri = "#{HETS_BASE_IRI}/#{command}/#{escaped_iri}"
      hets_iri << hets_api_options
      hets_iri << query_string

      FileUtils.rm_f(recorded_file(file))
      VCR.use_cassette(cassette_path_in_fixtures(file)) do
        send("http_request_with_#{method}", URI(hets_iri), header, data)
      end
    end

    def http_request_with_get(uri, _header, _data)
      Net::HTTP.get_response(uri)
    end

    def http_request_with_post(uri, header, data)
      Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request_post(uri, data.to_json, header)
      end
    end
  end
end
