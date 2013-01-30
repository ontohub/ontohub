class RdfDocument

  def initialize(triples)
  end

  def ranges(domain, relation)
    return []
  end

  def domains(range, relation)
    return []
  end

  # Return all relations between the given domain and range.
  def relations(domain, range)
    return []
  end
end
