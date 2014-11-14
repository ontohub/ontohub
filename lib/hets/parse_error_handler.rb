module Hets
  class ParseErrorHandler < UriFetcher::BaseErrorHandler

    # needs to return false if error cannot be handled by this instance.
    def perform
      error =
        if is_error? && is_text_response?
          try_file_not_available ||
            try_syntax_error
        end
      error ? raise error : false
    end

    def try_file_not_available
      if file_not_available?
        error = Hets::FileNotAvailableError.new <<-MSG
This file was not available: #{unavailable_file}
        MSG
        error
      end
    end

    def file_not_available?
      regex = /^failed to read contents of file: (.+)$/
      error_line_header? && after_header_starts_with(regex) do |match|
        self.unavailable_file = match[1]
      end
    end

    def error_line_header?
      lines.first.match(/^\s****\s+Error:\s*$/)
    end

    def after_header_starts_with(regex)
      match = lines[1].match(regex)
      yield match if block_given?
      !! match
    end

    def lines
      @lines ||= response.read_body.lines
    end

    def is_text_response?
      response.content_type == 'text/plain'
    end

    def is_error?
      response.is_a?(Net::HTTPClientError) ||
        response.is_a?(Net::HTTPServerError)
    end

  end
end
