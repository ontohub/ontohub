# A triple store
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class TripleStore

  # Constructs a triple store from an rdf file
  #
  # path_name - the path name of the rdf file to load
  #
  def load(path_name)
  end

  # Constructor
  #
  # triples - a list of triples
  #
  def initialize(triples)
  end

  # Returns a list with all ranges for a given domain-relation pair
  #
  # domain - a domain
  # relation = a relation
  #
  def ranges(domain, relation)
    return []
  end

  # Returns a list with all domains for a given range relation pair
  #
  # range - a range
  # relation - a relation
  #
  def domains(range, relation)
    return []
  end

  # Returns a list with all relations for a given domain-range pair
  #
  # domain - a domain
  # range - a range
  #
  def relations(domain, range)
    return []
  end

end
