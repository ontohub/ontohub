module UriFetcher
  include Errors

  NO_REDIRECT = 1

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
