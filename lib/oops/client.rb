module Oops::Client
  
  ENDPOINT = 'http://oops-ws.oeg-upm.net/rest'
  
  def self.request(url)
    Oops::Response.parse execute_request(url)
  end
  
  protected
  
  def self.execute_request(url)
    RestClient.post ENDPOINT, build_request(url)
  end
  
  def self.build_request(url)
    xml = '<?xml version="1.0" encoding="UTF-8"?>'
    xml << "\n<OOPSRequest>"
    xml << "<OntologyUrl>#{url}</OntologyUrl>"
    xml << "<OntologyContent></OntologyContent>"
    xml << "<Pitfalls></Pitfalls>"
    xml << "<OutputFormat>XML</OutputFormat>"
    xml << "</OOPSRequest>"
  end
  
end
