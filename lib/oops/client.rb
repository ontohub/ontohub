module Oops::Client

  ENDPOINT = 'http://oops-ws.oeg-upm.net/rest'

  def self.request(options)
    Oops::Response.parse execute_request(options)
  end

  protected

  def self.execute_request(options)
    a = {\
      method:       :post,
      url:          ENDPOINT,
      payload:      build_request(options),
      open_timeout: 30,     # Number of seconds to wait for the connection to open
      timeout:      60 * 15 # Number of seconds to wait for one block to be read
    }
    RestClient::Request.execute(a)# {|res, req, result| puts res}
  end

  def self.build_request(options)
    unless options.include?(:url) || options.include?(:content)
      raise ArgumentError, 'options must include :url or :content'
    end
    xml = '<?xml version="1.0" encoding="UTF-8"?>'
    xml << "\n<OOPSRequest>"
    xml << "<OntologyUrl>#{options[:url]}</OntologyUrl>"
    xml << "<OntologyContent>"
    xml << "<![CDATA[#{options[:content]}]]>" if options.include? :content
    xml << "</OntologyContent>"
    xml << "<Pitfalls></Pitfalls>"
    xml << "<OutputFormat>XML</OutputFormat>"
    xml << "</OOPSRequest>"
  end

end
