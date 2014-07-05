module Oops
  class Response

    Element = Struct.new(:type, :code, :name, :description, :affects)

    # Returns a list of Oops::Response::Element elements
    def self.parse(data)
      doc = Nokogiri::XML(data)
      if doc.root.name == 'RDF'
        raise Error, "OOPS wasn't able to reach ontohub.org"
      end

      doc.root.elements.map do |node|
        Element.new \
          node.name,
          node.xpath("oops:Code").text[1..-1].to_i,
          node.xpath("oops:Name").text,
          node.xpath("oops:Description").text,
          node.xpath("oops:Affects/*").map(&:text)
      end
    end

  end
end
