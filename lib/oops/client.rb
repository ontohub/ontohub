module Oops::Client
  
  ENDPOINT = 'http://oops-ws.oeg-upm.net/rest'
  
  def self.request(url)
    Oops::Response.parse execute_request(url)
  end
  
  protected
  
  def self.execute_request(url)
    RestClient::Request.execute \
      method:       :post,
      url:          ENDPOINT,
      payload:      build_request(url),
      open_timeout: 30,     # Number of seconds to wait for the connection to open
      timeout:      60 * 15 # Number of seconds to wait for one block to be read
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
