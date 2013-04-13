module Oops
  class Response
    
    Element = Struct.new(:type, :code, :name, :description, :affects)
    
    # Returns a list of Oops::Response::Element elements
    def self.parse(data)
      doc = Nokogiri::XML(data)
      if doc.root.name == 'RDF'
        raise Error, "got RDF response, expected XML"
      end
      
      doc.root.elements.map do |node|
        Element.new \
          node.name,
          node.xpath("oops:Code").text,
          node.xpath("oops:Name").text,
          node.xpath("oops:Description").text,
          node.xpath("oops:Affects/*").map(&:text)
      end
    end
    
  end
end