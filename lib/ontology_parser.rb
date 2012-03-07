module OntologyParser
  
  class ParseException < Exception; end
  
  # Parses the given string and executes the callback for each symbol
  def self.parse(input, callbacks)
    # Create a new parser
    parser = Nokogiri::XML::SAX::Parser.new(Listener.new(callbacks))
    
    # Feed the parser some XML
    parser.parse(input)
  end
  
  # Listener for the SAX Parser
  class Listener < Nokogiri::XML::SAX::Document
    
    ROOT   = 'Ontology'
    SYMBOL = 'Symbol'
    AXIOM  = 'Axiom'
    
    # the callback function is called for each Symbol tag
    def initialize(callbacks)
      @callbacks = callbacks
      @current_tag    = nil
      @current_symbol = nil
      @current_axiom  = nil
    end
    
    # a tag
    def start_element(name, attributes)
      @current_tag = name
      case name
        when ROOT
          callback(:ontology, Hash[*[attributes]])
        when SYMBOL
          @current_symbol = Hash[*[attributes]]
          @current_symbol['text'] = ''
        when AXIOM
          @current_axiom = Hash[*[attributes]]
          @current_axiom['symbols'] = []
        else
          # NOTHING
      end
    end
    
    # a text node
    def characters(text)
      if @current_tag == SYMBOL
        @current_symbol['text'] << text
      end
    end
    
    # closing tag
    def end_element(name)
      case name
        when SYMBOL
          if @current_axiom
            # add to current axiom
            @current_axiom['symbols'] << @current_symbol['text']
          else
            # return the current symcol
            callback(:symbol, @current_symbol)
          end
          @current_symbol = nil
        when AXIOM
          callback(:axiom, @current_axiom)
          @current_axiom = nil
      end
      
      @current_tag = nil
    end
    
    # error handler for parsing problems
    def error(string)
      raise ParseException, 'cannot parse: ' + string
    end
    
    private
    
    def callback(name, args)
      block = @callbacks[name]
      block.call(args) if block
    end
  
  end
  
end
