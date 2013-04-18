# This module parses the logic graph outputed by Hets.
#
# It is a use-once-and-discard code and for this reason it does not have
# regression tests.
#
# Author::    Daniel Couto Vale (mailto:danielvale@uni-bremen.de)
# Copyright:: Copyright (c) 2013 Bremen University, SFBTR8
# License::   Distributed as a part of Ontohub.
#
module LogicgraphParser

  class ParseException < Exception; end

  # Parses the given string and executes the callback for each symbol
  def self.parse(input, callbacks)
    print "parse\n"
    # Create a new parser
    parser = Nokogiri::XML::SAX::Parser.new(Listener.new(callbacks))

    # Feed the parser some XML
    parser.parse(input)
  end

  # Listener for the SAX Parser
  class Listener < Nokogiri::XML::SAX::Document
    
    ROOT            = 'LogicGraph'
    LOGIC           = 'logic'
    COMORPHISM      = 'comorphism'
    SOURCE_SUBLOGIC = 'sourceSublogic'
    TARGET_SUBLOGIC = 'targetSublogic'

    DESCRIPTION     = 'Description'
    SERIALIZATION   = 'Serialization'
    PROVER          = 'Prover'
    CONSERVATIVITY  = 'ConservativityChecker'
    CONSISTENCY     = 'ConsistencyChecker'

    # the callback function is called for each Symbol tag
    def initialize(callbacks)
      print "init\n"
      @callbacks        = callbacks
      @path             = []
      @current_logic = nil
      @current_language = nil
      @current_support = nil
      @current_logic_mapping = nil
      @mappings = Hash.new
      @logics = Hash.new
      @languages = Hash.new
      @supports = Hash.new
    end

    # Makes a logic mapping singleton for a given key
    def make_mapping(key)
      if @mappings[key] == nil
        mapping = LogicMapping.new
        mapping.iri = "http://perl.net/dol/logic-mapping/" + key
        mapping.standardization_status = "Unofficial"
        @mappings[key] = mapping
      end
      return @mappings[key]
    end

    # Make a logic singleton for a given key
    def make_logic(key)
      if @logics[key] == nil
        logic = Logic.new
        logic.iri = "http://perl.net/dol/logic/" + key
        logic.name = key
        logic.standardization_status = "Unofficial"
        @logics[key] = logic
      end
      return @logics[key]
    end
    
    # Make a language singleton for a given key
    def make_language(key)
      if @languages[key] == nil
        language = Language.new
        language.iri = "http://perl.net/dol/language/" + key
        language.name = key
        @languages[key] = language
      end
      return @languages[key]
    end

    def make_support(logicKey, languageKey)
      if @supports[logicKey] == nil
        @supports[logicKey] = Hash.new
      end
      if @supports[logicKey][languageKey] == nil
        support = Support.new
        support.logic = @logics[logicKey]
        support.language = @languages[languageKey]
        @supports[logicKey][languageKey] = support
      end
      return @supports[logicKey][languageKey]
    end
    
    # Parses the element opening tag
    def start_element(name, attributes)
      print "====>start "
      @path << name
      case name
        when ROOT
          print "graph"
          callback(:root, Hash[*[attributes]])
        when LOGIC
          print "logic "
          hash = Hash[*[attributes]]
          @current_logic = make_logic(hash['name'])
          @current_language = make_language(hash['name'])
          @current_support = make_support(hash['name'], hash['name'])
          callback(:logic, @current_logic)
          callback(:language, @current_language)
          callback(:support, @current_support)
        when COMORPHISM
          hash = Hash[*[attributes]]
          @current_comorphism = make_mapping(hash['name'])
          if @path[-2] == SOURCE_SUBLOGIC
            print "source sublogic comorphism"
            @current_comorphism.source = @current_source_sublogic
          elsif @path[-2] == TARGET_SUBLOGIC
            print "target sublogic comorphism"
            @current_comorphism.target = @current_target_sublogic
          else
            # TODO get attributes
            print "comorphism"
          end
        when SOURCE_SUBLOGIC
          print "source sublogic"
          hash = Hash[*[attributes]]
          @current_source_sublogic = make_logic(hash['name'])
          callback(:logic, @current_source_sublogic)
        when TARGET_SUBLOGIC
          print "target sublogic"
          hash = Hash[*[attributes]]
          @current_target_sublogic = make_logic(hash['name'])
          callback(:logic, @current_target_sublogic)
        when DESCRIPTION
          print "description"
        when SERIALIZATION
          hash = Hash[*[attributes]]
          print "serialization"
          name = hash['name']
          serialization = @current_language.serializations.create
          serialization.name = name
          serialization.extension = name
          serialization.mimetype = name
          @current_language.serializations << serialization
        when PROVER
          print "prover"
        when CONSERVATIVITY
          print "conservativity checker"
        when CONSISTENCY
          print "consistency checker"
      end
      print ".\n"
    end

    # Parses the element closing tag
    def end_element(name)
      print "======>end "
      @path.pop
      case name
        when ROOT
          print "graph\n"
        when LOGIC
          print "logic\n"
          callback(:logic, @current_logic)
          callback(:language, @current_language)
          callback(:support, @current_support)
          @current_logic = nil
          @current_language = nil
          @current_support = nil
        when COMORPHISM
          if @path[-1] == SOURCE_SUBLOGIC
            print "source sublogic comorphism\n"
          elsif @path[-1] == TARGET_SUBLOGIC
            print "target sublogic comorphism\n"
          else
            print "comorphism\n"
          end
          @current_comorphism = nil
        when SOURCE_SUBLOGIC
          print "source sublogic\n"
          @current_axiom = nil
        when TARGET_SUBLOGIC
          print "target sublogic\n"
          @current_link = nil
        when DESCRIPTION
          print "description\n"
        when SERIALIZATION
          print "serialization\n"
        when PROVER
          print "prover\n"
        when CONSERVATIVITY
          print "conservativity checker\n"
        when CONSISTENCY
          print "consistency checker\n"
      end
    end

    # Parses a text node
    def characters(text)
      case @path.last
        when DESCRIPTION
          @current_logic.description = text if @current_logic
          @current_language.description = text if @current_language
      end
      #case @path.last
      #  when SYMBOL
      #    @current_symbol['text'] << text if @current_symbol
      #  when TEXT
      #    @current_axiom['text'] << text if @current_axiom
      #  when TYPE # there is no other use of TYPE in this code
      #    @current_link['type'] = text if @current_link
      #end
    end

    # error handler for parsing problems
    # this exception is not being used so far
    def error(string)
      print "err\n"
      #raise ParseException, 'cannot parse: ' + string
    end
    
    private
    
    def callback(name, args)
      print "::callback\n"
      block = @callbacks[name]
      block.call(args) if block
    end
  
  end
  
end
