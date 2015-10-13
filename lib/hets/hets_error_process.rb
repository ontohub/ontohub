module Hets
  class HetsErrorProcess
    HETS_ERROR_CODES = %w(400, 422, 500)
    HETS_ERROR_MESSAGE_REGEXP = /\A[*]{3}\s*Error:\s*/

    attr_reader :error, :response
    delegate :body, to: :response

    def initialize(error)
      @error = error
      @response = error.last_response
    end

    def handle
      if hets_error?
        process_error
      else
        raise Hets::NotAHetsError.new('Error was not produced due to hets.')
      end
    end

    def process_error
      raise Hets::HetsFileError.new(message)
    end

    def hets_error?
      HETS_ERROR_CODES.include?(response.code) && error_header?
    end

    def message
      match = error_header.match(HETS_ERROR_MESSAGE_REGEXP)
      if match
        body[match[0].length..-1]
      else
        body_lines[1..-1].join("\n")
      end
    end

    def body_lines
      @body_lines ||= body.lines
    end

    def error_header
      body_lines.first
    end

    def error_header?
      !!(error_header =~ HETS_ERROR_MESSAGE_REGEXP)
    end
  end
end
