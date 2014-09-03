require 'uri'

module Hets
  class Caller
    include UriFetcher

    attr_accessor :hets_instance

    def initialize(hets_instance)
      self.hets_instance = hets_instance
    end

    def build_api_uri(command, arguments=[], query_string={})
      hierarchy = [hets_instance.uri, command, *arguments].join('/')
      query_part =
        if query_string && !query_string.empty?
          query_string.reduce('?') do |str, (key, val)|
            str << "#{key}=#{val};"
          end
        end
      api_uri = hierarchy + query_part.to_s
      URI.parse(api_uri)
    end

    def perform(api_uri, method=:get)
      raise NotImplementedError, 'No HTTP-Verb other than GET supported' unless method == :get
      fetch_uri_content(api_uri)
    end

    def has_actual_content?(response)
      response.is_a?(Net::HTTPSuccess)
    end

  end
end
