module UriFetcher
  include Errors
  DEFAULT_REDIRECTS = 10

  class HTTPCaller
    include UriFetcher::Errors

    attr_accessor :uri, :data, :redirect_limit
    attr_accessor :previous_response, :current_response
    attr_accessor :content_test_block, :write_file, :file_type
    attr_writer :error_handler

    def initialize(uri, data: {}, redirect_limit: DEFAULT_REDIRECTS)
      self.uri = uri
      self.data = data
      self.redirect_limit = redirect_limit
    end

    def error_handler
      @error_handler ||= BaseErrorHandler.new(self)
    end

    # Currently only File and Tempfile are
    # allowed for file_type.
    def call(write_file: nil, file_type: File)
      self.write_file = write_file
      self.file_type = file_type
      fetch
    end

    def fetch
      check_redirections_count
      result = nil
      make_http_request(URI(uri)) { |r| result = handle_response(r) }
      result
    end

    def has_actual_content_through(&block)
      self.content_test_block = block
    end

    protected

    def make_http_request(uri, &block)
      raise NotImplementedError
    end

    private
    def check_redirections_count
      if redirect_limit == 0
        raise TooManyRedirectionsError.new(last_response: previous_response)
      end
    end

    def handle_response(response)
      self.current_response = response
      if has_actual_content?(response)
        provide_result(response)
      elsif is_redirection?(response)
        response.read_body
        recall
      else
        try_error_handling_or_do(response) do
          response.read_body
          raise UnfollowableResponseError.new(last_response: response)
        end
      end
    end

    def try_error_handling_or_do(response, &block)
      success_response = error_handler.call(response)
      success_response == false ? block.call : success_response
    end

    def recall
      self.redirect_limit -= 1
      self.previous_response = current_response
      call(write_file: write_file, file_type: file_type)
    end

    def is_redirection?(response)
      response['location'] && !response['location'].empty?
    end

    def has_actual_content?(response)
      if self.content_test_block
        content_test_block.call(response)
      else
        response.is_a?(Net::HTTPSuccess) &&
          response.content_type != 'text/html'
      end
    end

    def provide_io
      if write_file
        if file_type == File
          file_type.new(write_file, 'w+')
        elsif file_type == Tempfile
          file_type.new('uri-fetcher')
        end
      else
        ''
      end
    end

    def provide_result(response)
      io = provide_io
      response.read_body { |chunk| io << chunk }
      io.rewind if io.respond_to?(:rewind)
      io
    end

    def data_json
      (data || {}).to_json
    end
  end
end
