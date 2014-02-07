module URI
  class << self

    def valid?(string)
      URI.parse(string)
      true
    rescue URI::InvalidURIError
      false
    end

  end
end
