class StatusOntologyViewhelper < ViewhelperBase
  include WrappingRedis

  STATE = 'processing'

  def processing_ontologies_count
    processing_ontology_query.size
  end

  def processing_ontology_data
    @data ||= procure_processing_ontology_data
  end

  def procure_processing_ontology_data
    ov_data = processing_ontology_query.reduce({}) do |data, ov|
      # usually iri, second part is just for uniqueness
      key = ov.ontology.iri || "#{ov.ontology.name}#{ov.ontology.path}"
      data[key] = OpenStruct.new({
        ontology: ov.ontology,
        ontology_version: ov,
        running_for: view.time_ago_in_words(ov.state_updated_at),
        processing_iri: nil
      })
      data
    end
    processing_iris.reduce(ov_data) do |data, iri|
      if data[iri]
        data[iri].processing_iri = iri
      else
        data[iri] = OpenStruct.new({processing_iri: iri})
      end
      data
    end.values
  end

  def any_processing_ontologies?
    processing_ontology_query.any?
  end

  def processing_iris
    redis.smembers ConcurrencyBalancer::REDIS_KEY
  end

  private
  def processing_ontology_query
    OntologyVersion.where(state: STATE).order('state_updated_at ASC')
  end

end
