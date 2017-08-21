module UriFetcher
  class GetCaller < HTTPCaller
    def make_http_request(uri, &block)
      Net::HTTP.start(uri.hostname, uri.port,
        use_ssl: uri.scheme == 'https') do |http|
        http.read_timeout = timeout if timeout
        return http.request_get(URI(uri), &block)
      end
    end
  end
end
