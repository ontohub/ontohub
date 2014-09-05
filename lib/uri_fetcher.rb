module UriFetcher
  include Errors

  NO_REDIRECT = 1
  DEFAULT_REDIRECTS = 10

  class GetCaller
    attr_accessor :uri, :redirect_limit, :previous_response, :current_response
    attr_accessor :content_test_block, :write_file, :file_type

    def initialize(uri, redirect_limit: DEFAULT_REDIRECTS)
      self.uri = uri
      self.redirect_limit = redirect_limit
    end

    def call(write_file: nil, file_type: File)
      self.write_file = write_file
      self.file_type = file_type
      fetch
    end

    def fetch
      check_redirections_count
      result = nil
      Net::HTTP.get_response(URI(uri)) { |r| result = handle_response(r) }
      result
    end

    def has_actual_content_through(&block)
      self.content_test_block = block
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
        response.read_body
        raise UnfollowableResponseError.new(last_response: response)
      end
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
  end

  def fetch_uri_content(uri, limit: 10, write_file: nil, prev_resp: nil)
    raise TooManyRedirectionsError.new(last_response: prev_resp) if limit == 0
    Net::HTTP.get_response(URI(uri)) do |response|
      response.read_body
      if has_actual_content?(response)
        produce_response_body(response, write_file)
      elsif response['location'] && !response['location'].empty?
        fetch_uri_content(response['location'],
                                    limit: limit-1,
                                    write_file: write_file,
                                    prev_resp: response)
      else
        raise UnfollowableResponseError.new(last_response: response)
      end
    end
  end

  private
  def produce_response_body(response, write_file=nil)
    if write_file
      File.open(write_file.to_s, 'w') do |file|
        file.flock(File::LOCK_EX)
        response.read_body do |chunk|
          file.write chunk
        end
      end
      write_file
    else
      response.body
    end
  end

  def has_actual_content?(response)
    response.is_a?(Net::HTTPSuccess) && response.content_type != 'text/html'
  end

end
