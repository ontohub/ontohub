module URI
  class << self

    def valid?(string)
      !!URI.parse(string)
    rescue URI::InvalidURIError
      false
    end

  end
end
