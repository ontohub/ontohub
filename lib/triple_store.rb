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
      @subjectMap = map_entity(@subjectMap, predicate, object, subject)

      # Map predicate
      @predicateMap = map_entity(@predicateMap, subject, object, predicate)

      # Map object
      @objectMap = map_entity(@objectMap, subject, predicate, object)
    end
  end

  # Returns a list with all subjects for a given object-predicate pair
  #
  # * *Args* :
  # * - +predicate+ -> a predicate
  # * - +object+ -> a range
  # * *Returns* :
  # * - the list of subjects for given predicate and range
  def subjects(predicate, object)
    entities(@subjectMap[predicate], object)
  end

  # Returns a list with all predicates for a given subject-object pair
  #
  # * *Args* :
  # * - +subject+ -> a domain
  # * - +object+ -> a range
  # * *Returns* :
  # * - the list of predicates for given domain and range
  def predicates(subject, object)
    return entities(@predicateMap[subject], object)
  end

  # Returns a list with all objects for a given subject-predicate pair
  #
  # * *Args* :
  # * - +subject+ -> a domain
  # * - +predicate+ -> a relation
  # * *Returns* :
  # * - the list of objects for given domain and relation
  def objects(subject, predicate)
    return entities(@objectMap[subject], predicate)
  end

  private

  # Lists the entities with the given restrictions
  #
  # * *Args* :
  # * - +hash+ -> a hash of arrays
  # * - +key+ -> a key of the array
  # * *Returns* :
  # * - the indicated entity array if it exists
  # * - an empty array otherwise
  def entities(hash, key)
    if !hash
      return Array.new
    elsif !hash[key]
      return Array.new
    else
      return Array.new(hash[key])
    end
  end

  # Maps an entity with two keys
  #
  # * *Args* :
  # * - +map+ -> a hash of hashes of arrays
  # * - +key1+ -> a key to a hash of arrays
  # * - +key2+ -> a key to an array
  # * - +entity+ -> an entity to be added to the array
  # * *Returns* :
  # * - the updated map containing the entity
  def map_entity(map, key1, key2, entity)
    unless map[key1]
      map[key1] = Hash.new
    end
    unless map[key1][key2]
      map[key1][key2] = Array.new
    end
    map[key1][key2].push entity
    return map
  end

end
