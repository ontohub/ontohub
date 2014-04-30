module UriFetcher

  def fetch_uri_content(uri, limit: 10, write_file: nil)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0
    Net::HTTP.get_response(URI(uri)) do |response|
      if has_actual_content?(response)
        produce_response_body(response, write_file)
      else
        fetch_uri_content(response['location'],
                                    limit: limit-1,
                                    write_file: write_file)
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
