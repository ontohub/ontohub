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

  def errored_version_query
    OntologyVersion.includes(:ontology).
      where(state: STATE).
      where(ontology_id: errored_ontology_query)
  end

  def errored_ontology_data
    @data ||= procure_errored_ontology_data
  end

  # Relies on the 'old' state_message method
  # for. Should be improved later on.
  def procure_errored_ontology_data
    errored_version_query.group_by(&:state_message)
  end

end
