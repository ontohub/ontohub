require 'rdf'
require 'rdf/rdfxml'
require 'rdf/ntriples'

# A triple store of relational statements (Subject, Predicate, Object)
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class TripleStore

  # A map (predicate x object) -> subject
  @subjectMap

  # A map (subject x object) -> predicate
  @predicateMap

  # A map (subject x predicate) -> object
  @objectMap

  # Constructs a statement store from an rdf file
  #
  # path_name - the path name of the rdf file to load
  #
  def self.load(path_name)
    statements = []
    RDF::RDFXML::Reader.open(path_name) do |reader|
      statements = reader.statements.to_a
    end && 0
    return TripleStore.new statements
  end

  # Constructor
  #
  # statements - a list of statements
  #
  def initialize(statements)
    @subjectMap = Hash.new
    @predicateMap = Hash.new
    @objectMap = Hash.new
    statements.each do |statement|

      # Read statement components
      subject = statement[0].to_s
      predicate = statement[1].to_s
      object = statement[2].to_s

      # Map subject
      if @subjectMap[predicate] == nil
        @subjectMap[predicate] = Hash.new
      end
      if @subjectMap[predicate][object] == nil
        @subjectMap[predicate][object] = Array.new
      end
      @subjectMap[predicate][object].push subject

      # Map predicate
      if @predicateMap[subject] == nil
        @predicateMap[subject] = Hash.new
      end
      if @predicateMap[subject][object] == nil
        @predicateMap[subject][object] = Array.new
      end
      @predicateMap[subject][object].push predicate

      # Map object
      if @objectMap[subject] == nil
        @objectMap[subject] = Hash.new
      end
      if @objectMap[subject][predicate] == nil
        @objectMap[subject][predicate] = Array.new
      end
      @objectMap[subject][predicate].push object
    end
  end

  # Returns a list with all subjects for a given object-predicate pair
  #
  # predicate - a predicate
  # object - a range
  #
  def subjects(predicate, object)
    if @subjectMap[predicate] == nil
      return Array.new
    elsif @subjectMap[predicate][object] == nil
      return Array.new
    else
      return Array.new(@subjectMap[predicate][object])
    end
  end

  # Returns a list with all predicates for a given subject-object pair
  #
  # subject - a domain
  # object - a range
  #
  def predicates(subject, object)
    if @predicateMap[subject] == nil
      return Array.new
    elsif @predicateMap[subject][object] == nil
      return Array.new
    else
      return Array.new(@predicateMap[subject][object])
    end
  end

  # Returns a list with all objects for a given subject-predicate pair
  #
  # subject - a domain
  # predicate - a relation
  #
  def objects(subject, predicate)
    if @objectMap[subject] == nil
      return Array.new
    elsif @objectMap[subject][predicate] == nil
      return Array.new
    else
      return Array.new(@objectMap[subject][predicate])
    end
  end

end
