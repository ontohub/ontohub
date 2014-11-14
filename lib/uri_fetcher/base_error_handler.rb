module UriFetcher
  class BaseErrorHandler
    attr_reader :http_caller, :response

    def initialize(http_caller)
      @http_caller = http_caller
    end

    def call(response)
      @response = response
      perform
    end

    # returns false if it was not able to handle the error
    def perform
      false
    end
  end
end
