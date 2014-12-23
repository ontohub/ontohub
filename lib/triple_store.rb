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
    end
    TripleStore.new statements
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
      map_entity(@subjectMap, predicate, object, subject)

      # Map predicate
      map_entity(@predicateMap, subject, object, predicate)

      # Map object
      map_entity(@objectMap, subject, predicate, object)
    end
  end

  # Returns a list with all subjects for a given object-predicate pair
  #
  # * *Args* :
  # * - +predicate+ -> a predicate
  # * - +object+ -> an object
  # * *Returns* :
  # * - the list of subjects
  def subjects(predicate, object)
    entities(@subjectMap, predicate, object)
  end

  # Returns a list with all predicates for a given subject-object pair
  #
  # * *Args* :
  # * - +subject+ -> a subject
  # * - +object+ -> an object
  # * *Returns* :
  # * - the list of predicates
  def predicates(subject, object)
    entities(@predicateMap, subject, object)
  end

  # Returns a list with all objects for a given subject-predicate pair
  #
  # * *Args* :
  # * - +subject+ -> a subject
  # * - +predicate+ -> a predicate
  # * *Returns* :
  # * - the list of objects
  def objects(subject, predicate)
    entities(@objectMap, subject, predicate)
  end

  private

  # Lists the entities identified by two keys
  #
  # * *Args* :
  # * - +map+ -> a hash of hashes of arrays
  # * - +key1+ -> a key to a hash of arrays
  # * - +key2+ -> a key to an array
  # * *Returns* :
  # * - the indicated array of entities if it exists
  # * - an empty array otherwise
  def entities(map, key1, key2)
    if !map[key1]
      Array.new
    elsif !map[key1][key2]
      Array.new
    else
      Array.new(map[key1][key2])
    end
  end

  # Maps an entity to two keys
  #
  # * *Args* :
  # * - +map+ -> a hash of hashes of arrays
  # * - +key1+ -> a key to a hash of arrays
  # * - +key2+ -> a key to an array
  # * - +entity+ -> an entity to be added to the array
  def map_entity(map, key1, key2, entity)
    if !map[key1]
      map[key1] = Hash.new
    end
    if !map[key1][key2]
      map[key1][key2] = Array.new
    end
    map[key1][key2].push entity
  end

end
