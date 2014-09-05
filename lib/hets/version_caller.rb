module Hets
  class VersionCaller < Caller

    CMD = 'version'
    METHOD = :get

    def call
      api_uri = build_api_uri(CMD)
      perform(api_uri, METHOD)
    rescue UriFetcher::Error
      Rails.logger.warn <<-MSG
==HETS== Hets Instance <#{hets_instance}> is currently not reachable.
      MSG
      nil
    end

    def http_result_options
      {}
    end

  end
end
