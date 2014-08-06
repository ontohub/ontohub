class StatusOntologyViewhelper < ViewhelperBase

  STATE = 'processing'

  def processing_ontologies_count
    processing_ontology_query.size
  end

  def processing_ontology_data
    @data ||= processing_ontology_query.map do |ov|
      OpenStruct.new({
        ontology: ov.ontology,
        ontology_version: ov,
        running_for: view.time_ago_in_words(ov.state_updated_at),
      })
    end
  end

  def any_processing_ontologies?
    processing_ontology_query.any?
  end

  private
  def processing_ontology_query
    OntologyVersion.where(state: STATE).order('state_updated_at ASC')
  end

end
