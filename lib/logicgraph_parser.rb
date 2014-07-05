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
      @mappings[key] ||= begin
        mapping = LogicMapping.new
        mapping.iri = "http://purl.net/dol/logic-mapping/" + key
        mapping.standardization_status = "Unofficial"
        mapping
      end
    end

    # Make a logic singleton for a given key
    def make_logic(key)
      @logics[key] ||= begin
        iri = "http://purl.net/dol/logics/" + key
        logic = Logic.find_by_iri iri
        if logic.nil?
          logic = Logic.new
          logic.iri = iri
          logic.name = key
          logic.standardization_status = "Unofficial"
        end
        logic
      end
    end

    # Make a language singleton for a given key
    def make_language(key)
      @languages[key] ||= begin
        iri = "http://purl.net/dol/language/" + key
        language = Language.find_by_iri iri
        if language.nil?
          language = Language.new
          language.iri = iri
          language.name = key
        end
        language
      end
    end

    def make_support(logic_key, language_key)
      @supports[logic_key] ||= {}
      @supports[logic_key][language_key] ||= begin
        logic = @logics[logic_key]
        language = @languages[language_key]
        support = Support.where(logic_id: logic, language_id: language).first
        if support.nil?
          support = Support.new
          support.logic = @logics[logic_key]
          support.language = @languages[language_key]
        end
        support
      end
    end

    # Parses the element opening tag
    def start_element(name, attributes)
      @path << name
      case name
        when ROOT
          callback(:root, Hash[*[attributes]])
        when LOGIC
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
            # @current_comorphism.source = @current_source_sublogic
          elsif @path[-2] == TARGET_SUBLOGIC
            # @current_comorphism.target = @current_target_sublogic
          else
            # Get attributes
            if hash['is_weakly_amalgamable'] == 'TRUE'
              @current_comorphism.exactness = LogicMapping::EXACTNESSES[2]
            else
              @current_comorphism.exactness = LogicMapping::EXACTNESSES[0]
            end
            if hash['has_model_expansion'] == 'TRUE'
              @current_comorphism.faithfulness = LogicMapping::FAITHFULNESSES[2]
            else
              @current_comorphism.faithfulness = LogicMapping::FAITHFULNESSES[0]
            end
            if hash['source']
              @current_comorphism.source = make_logic(hash['source'])
            end
            if hash['target']
              @current_comorphism.target = make_logic(hash['target'])
            end
          end
          if !@current_comorphism.source.nil? && !@current_comorphism.target.nil?
            callback(:logic_mapping, @current_comorphism)
          end
        when SOURCE_SUBLOGIC
          hash = Hash[*[attributes]]
          @current_source_sublogic = make_logic(hash['name'])
          callback(:logic, @current_source_sublogic)
        when TARGET_SUBLOGIC
          hash = Hash[*[attributes]]
          @current_target_sublogic = make_logic(hash['name'])
          callback(:logic, @current_target_sublogic)
        when DESCRIPTION
        when SERIALIZATION
          hash = Hash[*[attributes]]
          name = hash['name']
          serialization = @current_language.serializations.create
          serialization.name = name
          serialization.extension = name
          serialization.mimetype = name
          @current_language.serializations << serialization
        when PROVER
        when CONSERVATIVITY
        when CONSISTENCY
      end
    end

    # Parses the element closing tag
    def end_element(name)
      @path.pop
      case name
        when ROOT
        when LOGIC
          callback(:logic, @current_logic)
          callback(:language, @current_language)
          callback(:support, @current_support)
          @current_logic = nil
          @current_language = nil
          @current_support = nil
        when COMORPHISM
          if @path[-1] == SOURCE_SUBLOGIC
          elsif @path[-1] == TARGET_SUBLOGIC
          else
            callback(:logic_mapping, @current_comorphism)
          end
          @current_comorphism = nil
        when SOURCE_SUBLOGIC
          @current_axiom = nil
        when TARGET_SUBLOGIC
          @current_link = nil
        when DESCRIPTION
        when SERIALIZATION
        when PROVER
        when CONSERVATIVITY
        when CONSISTENCY
      end
    end

    # Parses a text node
    def characters(text)
      case @path.last
        when DESCRIPTION
          @current_logic.description = text if @current_logic
          @current_language.description = text if @current_language
      end
    end

    private

    def callback(name, args)
      @callbacks[name].try :call, args
    end

  end

end
