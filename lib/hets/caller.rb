require 'uri'

module Hets
  class Caller
    include UriFetcher

    STRING_RESPONSE = {}
    TEMPFILE_RESPONSE = {write_file: true, file_type: Tempfile}

    attr_accessor :hets_instance

    def initialize(hets_instance)
      self.hets_instance = hets_instance
    end

    def build_api_uri(command, arguments = [], query_string = {})
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

    def perform(api_uri, data = {}, method = :get)
      caller = performing_instance(api_uri, data, method)
      caller.call(http_result_options)
    end

    def http_result_options
      TEMPFILE_RESPONSE
    end

    def performing_instance(api_uri, data, method)
      caller = caller_class(method).new(api_uri, data: data)
      caller.has_actual_content_through do |response|
        has_actual_content?(response)
      end
      caller
    end

    def has_actual_content?(response)
      response.is_a?(Net::HTTPSuccess)
    end

    def caller_class(method)
      case method
      when :get
        GetCaller
      when :post
        PostCaller
      else
        raise NotImplementedError, 'No HTTP-Verb other than GET, POST supported'
      end
    end
  end
end
