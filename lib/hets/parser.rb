module Hets
  class Parser
    attr_accessor :path, :callback

    def initialize(xml_path)
      self.path = xml_path
    end

    def parse(callback: nil)
      input = File.open(path)
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
