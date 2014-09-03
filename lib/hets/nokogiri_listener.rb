module Hets
  class NokogiriListener < Nokogiri::XML::SAX::Document
    MAP = "map"
    ROOT = 'DGraph'
    ONTOLOGY = 'DGNode'
    SYMBOL = 'Symbol'
    SYMBOL_LIST = 'Symbols'
    AXIOM = 'Axiom'
    IMPAXIOMS = 'ImpAxioms'
    AXIOMS = 'Axioms'
    LINK = 'DGLink'
    TEXT = 'Text'
    TYPE = 'Type'
    MORPHISM = 'GMorphism'
    IMPORT = 'Reference'

    CALLBACK_MAP = {
      ONTOLOGY => :ontology,
      SYMBOL => :symbol,
      AXIOM => :axiom,
      LINK => :link,
    }

    # callback#process method is called when an element is ready to be
    # processed
    def initialize(callback)
      @callback = callback
      @path             = []
      @current_ontology = nil
      @current_symbol   = nil
      @current_axiom    = nil
      @current_link     = nil
      @in_imp_axioms    = false
    end

    def call_back(element_name, order, *args)
      if @callback
        @callback.process(element_name, order, *args)
      end
    end

    # a tag
    def start_element(name, attributes)
      order = :start
      @path << name
      case name
      when ROOT
        call_back(:root, order, Hash[*[attributes]])
      when ONTOLOGY
        call_back(:ontology, order, Hash[*[attributes]])
      when IMPORT
        call_back(:import, order, Hash[*[attributes]])
      when SYMBOL
        @current_symbol = Hash[*[attributes]]
        @current_symbol['text'] = ''
        if @current_link && @current_link['map']
          @current_link['map'] << @current_symbol
        end
        @current_axiom['symbol_hashes'] << @current_symbol if @current_axiom
      when SYMBOL_LIST
        @in_symbol_list = true
      when IMPAXIOMS
        @in_imp_axioms = true
      when AXIOMS
        @in_axioms = true
      when AXIOM
        @current_axiom = Hash[*[attributes]]
        @current_axiom['symbols'] = []
        @current_axiom['symbol_hashes'] = []
        @current_axiom['text'] = ''
      when LINK
        @current_link = Hash[*[attributes]]
      when MORPHISM
        @current_link['morphism'] = Hash[*[attributes]]['name'] if @current_link
      when MAP
        @current_link['map'] = []
      end
    end

    # a text node
    def characters(text)
      case @path.last
      when SYMBOL
        @current_symbol['text'] << text if @current_symbol
      when TEXT
        @current_axiom['text'] << text if @current_axiom
      when TYPE # there is no other use of TYPE in this code
        @current_link['type'] = text if @current_link
      end
    end

    # closing tag
    def end_element(name)
      order = :end
      @path.pop

      case name
      when ONTOLOGY
        call_back(:ontology, order, @current_ontology)
        @current_ontology = nil
      when SYMBOL
        return if @path.last == 'Hidden'

        if @current_axiom
          # add to current axiom
          @current_axiom['symbols'] << @current_symbol['text']
        else
          # return the current symcol
          in_mapping_link = @current_link && @current_link['map']
          perform_callback = @in_symbol_list && !in_mapping_link
          call_back(:symbol, order, @current_symbol) if perform_callback
        end
        @current_symbol = nil
      when SYMBOL_LIST
        @in_symbol_list = false
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
          call_back(:imported_axiom, order, @current_axiom)
        elsif @in_axioms
          call_back(:axiom, order, @current_axiom)
        end
        # return the current axiom
        @current_axiom = nil
      when LINK
        # return the current link
        call_back(:link, order, @current_link)
        @current_link = nil
      end
    end

  end
end
