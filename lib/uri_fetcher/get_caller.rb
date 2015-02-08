module UriFetcher
  class GetCaller < HTTPCaller
    def make_http_request(uri, &block)
      Net::HTTP.get_response(URI(uri), &block)
    end
  end
end
