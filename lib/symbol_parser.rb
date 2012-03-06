module SymbolParser
  
  class ParseException < Exception; end
  
  # Parses the given string and executes the callback for each symbol
  def self.parse(input, &callback)
    # Create a new parser
    parser = Nokogiri::XML::SAX::Parser.new(Listener.new(&callback))
    
    # Feed the parser some XML
    parser.parse(input)
  end
  
  # Listener for the SAX Parser
  class Listener < Nokogiri::XML::SAX::Document
    
    # the callback function is called for each Symbol tag
    def initialize(&callback)
      raise ArgumentError, "no block given" unless block_given?
      
      @callback = callback
      @current_symbol = nil
    end
    
    # a tag
    def start_element(name, attributes)
      case name
        when 'Symbols'
          # do nothing
        when 'Symbol'
          @current_symbol = Hash[*[attributes]]
        else
          raise ParseException, "unsupported element: #{name}"
      end
    end
    
    # a text node
    def characters(text)
      @current_symbol['text'] = text if @current_symbol
    end
    
    # closing tag
    def end_element(name)
      if name == 'Symbol'
        @callback.call(@current_symbol)
      end
      
      @current_symbol = nil
    end
    
    # error handler for parsing problems
    def error(string)
      raise ParseException, 'cannot parse: ' + string
    end
  
  end
  
end