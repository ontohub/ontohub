module URI
  class << self

    def valid?(string)
      URI.parse(string)
      return true
    rescue URI::InvalidURIError
      return false
    end

  end
end
