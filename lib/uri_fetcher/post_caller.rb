module UriFetcher
  class PostCaller < HTTPCaller
    HEADER = {'Content-Type' => 'application/json'}

    def make_http_request(uri, &block)
      Net::HTTP.start(uri.hostname, uri.port,
        use_ssl: uri.scheme == 'https') do |http|
        return http.request_post(uri, data_json, HEADER, &block)
      end
    end
  end
end
