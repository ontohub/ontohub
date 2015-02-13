module Hets
  class HetsErrorProcess
    HETS_ERROR_CODES = %w(400, 422)

    attr_reader :error, :response
    delegate :body, to: :response

    def initialize(error)
      @error = error
      @response = error.last_response
    end

    def handle
      if is_hets_error?
        process_error
      else
        raise Hets::NotAHetsError.new('Error was not produced due to hets.')
      end
    end

    def process_error
      raise Hets::HetsFileError.new(message)
    end

    def is_hets_error?
      HETS_ERROR_CODES.include?(response.code) && error_header?
    end

    def message
      body_lines.slice(1..-1).join
    end

    def body_lines
      @body_lines ||= body.lines
    end

    def error_header
      body_lines.first
    end

    def error_header?
      !!(error_header =~ /\A[*]{3}\s*Error:\s*\Z/)
    end
  end
end
