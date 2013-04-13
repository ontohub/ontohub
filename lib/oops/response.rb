module Oops
  class Response
    
    # 
    def self.parse(data)
      doc = Nokogiri::XML(data)
      if doc.root.name == 'RDF'
        raise Error, "got RDF response, expected XML"
      end
    end
    
  end
end