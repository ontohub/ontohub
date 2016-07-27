require_relative 'base_generator.rb'

module FixturesGeneration
  class DirectHetsGenerator < BaseGenerator
    HETS_API_OPTIONS = '/auto'
    HETS_BASE_IRI = "http://localhost:#{HETS_SERVER_PORT}"

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
      hets_iri << "?#{input_type(file)}"
      hets_iri << ";#{query_string}" if query_string

      FileUtils.rm_f(recorded_file(file))
      VCR.use_cassette(cassette_path_in_fixtures(file)) do
        http_request(method, URI(hets_iri), header, data)
      end
    end

    def http_request(method, uri, header, data)
      case method
      when :get
        Net::HTTP.get_response(uri)
      when :post
        Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request_post(uri, data.to_json, header)
        end
      else
        raise "HTTP method #{method} is not supported."
      end
    end

    def input_type(file)
      extension = File.extname(file)
      type =
        Ontology::HetsOptions::EXTENSIONS_TO_INPUT_TYPES[extension] ||
        extension[1..-1]
      type ? "input-type=#{type}" : ''
    end
  end
end
