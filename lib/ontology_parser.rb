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
    MAP       = 'map'
    ROOT      = 'DGraph'
    ONTOLOGY  = 'DGNode'
    SYMBOL    = 'Symbol'
    AXIOM     = 'Axiom'
    THEOREM   = 'Theorem'
    IMPAXIOMS = 'ImpAxioms'
    AXIOMS    = 'Axioms'
    THEOREMS  = 'Theorems'
    MAPPING   = 'DGLink'
    TEXT      = 'Text'
    TYPE      = 'Type'
    MORPHISM  = 'GMorphism'
    IMPORT    = 'Reference'

    # the callback function is called for each Symbol tag
    def initialize(callbacks)
      @callbacks        = callbacks
      @path             = []
      @current_ontology = nil
      @current_symbol   = nil
      @current_axiom    = nil
      @current_mapping     = nil
      @in_imp_axioms    = false
    end

    # a tag
    def start_element(name, attributes)
      @path << name
      case name
      when ROOT
        callback(:root, Hash[*[attributes]])
      when ONTOLOGY
        callback(:ontology, Hash[*[attributes]])
      when IMPORT
        callback(:import, Hash[*[attributes]])
      when SYMBOL
        @current_symbol = Hash[*[attributes]]
        @current_symbol['text'] = ''
        if @current_mapping && @current_mapping['map']
          @current_mapping['map'] << @current_symbol
        end
        @current_axiom['symbol_hashes'] << @current_symbol if @current_axiom
      when IMPAXIOMS
        @in_imp_axioms = true
      when AXIOMS
        @in_axioms = true
      when AXIOM
        @current_axiom = Hash[*[attributes]]
        @current_axiom['symbols'] = []
        @current_axiom['symbol_hashes'] = []
        @current_axiom['text'] = ''
      when THEOREMS
        @in_theorems = true
      when THEOREM
        @current_theorem = Hash[*[attributes]]
        @current_theorem['symbols'] = []
        @current_theorem['symbol_hashes'] = []
        @current_theorem['text'] = ''
      when MAPPING
        @current_mapping = Hash[*[attributes]]
      when MORPHISM
        @current_mapping['morphism'] = Hash[*[attributes]]['name'] if @current_mapping
      when MAP
        @current_mapping['map'] = []
      end
    end

    # a text node
    def characters(text)
      case @path.last
      when SYMBOL
        @current_symbol['text'] << text if @current_symbol
      when TEXT
        @current_axiom['text'] << text if @current_axiom
        @current_theorem['text'] << text if @current_theorem
      when TYPE # there is no other use of TYPE in this code
        @current_mapping['type'] = text if @current_mapping
      end
    end

    # closing tag
    def end_element(name)
      @path.pop

      case name
      when ONTOLOGY
        callback(:ontology_end, @current_ontology)
        @current_ontology = nil
      when SYMBOL
        return if @path.last == 'Hidden'

        if @current_axiom
          # add to current axiom
          @current_axiom['symbols'] << @current_symbol['text']
        elsif @current_theorem
          # add to current theorem
          @current_theorem['symbols'] << @current_symbol['text']
        else
          # return the current symbol
          in_mapping_mapping = @current_mapping && @current_mapping['map']
          callback(:symbol, @current_symbol) unless in_mapping_mapping
        end
        @current_symbol = nil
      when IMPAXIOMS
        @in_imp_axioms = false
      when AXIOMS
        @in_axioms = false
      when AXIOM
        # do not execute callbacks
        # unless the axiom was inside a
        # <Axioms> element or a <ImpAxioms>
        # element
        if @in_imp_axioms
          callback(:imported_axiom, @current_axiom)
        elsif @in_axioms
          callback(:axiom, @current_axiom)
        end
        # return the current axiom
        @current_axiom = nil
      when THEOREMS
        @in_theorems = false
      when THEOREM
        callback(:theorem, @current_theorem) if @in_theorems
        # return the current theorem
        @current_theorem = nil
      when MAPPING
        # return the current mapping
        callback(:mapping, @current_mapping)
        @current_mapping = nil
      end
    end

    # error handler for parsing problems
    # this exception is not being used so far
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
