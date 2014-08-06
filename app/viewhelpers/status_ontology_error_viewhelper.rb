class StatusOntologyErrorViewhelper < ViewhelperBase

  STATE = 'failed'

  def errored_ontologies_count
    errored_ontology_query.size
  end

  def any_errored_ontologies?
    errored_ontology_query.any?
  end

  def errored_ontology_query
    Ontology.where(state: STATE)
  end

end
