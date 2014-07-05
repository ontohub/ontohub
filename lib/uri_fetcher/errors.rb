module UriFetcher
  module Errors
    class Error < StandardError; end
    class ArgumentError < ::ArgumentError; end

    class TooManyRedirectionsError < ArgumentError
      DEFAULT_MSG = 'too many HTTP redirects encountered'

      attr_reader :last_response

      def initialize(msg=DEFAULT_MSG, last_response: nil)
        @last_response = last_response
        super(msg)
      end

    end

    class UnexpectedStatusCodeError < Error

      attr_reader :response, :status_code

      # Status-Code should be only used as an option if
      # you don't have the response object available.
      def initialize(msg=nil, response: nil, status_code: nil)
        @response = response
        @status_code = response ? response.code : status_code
        super(msg || generate_message)
      end

      def generate_message
        <<-ERROR
Encountered an unexpected status code of #{status_code}.
#{"Here is the full response: <#{response}>" if response}
        ERROR
      end

    end

  end
end
