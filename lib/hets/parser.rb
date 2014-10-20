module Hets
  class Parser
    attr_accessor :resource, :callback

    def initialize(resource)
      self.resource = resource
    end

    def parse(callback: nil)
      input = resource.respond_to?(:close) ? resource : File.open(resource)
      parser(callback).parse(input)
      input.close
    end

    private
    def parser(callback)
      listener = NokogiriListener.new(callback)
      Nokogiri::XML::SAX::Parser.new(listener)
    end

  end
end
