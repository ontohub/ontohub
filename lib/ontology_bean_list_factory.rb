require 'json'

class OntologyBeanListFactory

  attr_reader :bean_list

  def initialize
    @bean_list = []
  end

  def add_small_bean(ontology)
    @bean_list.push(make_small_bean(ontology)) if @bean_list.size < 50
  end

  def make_small_bean(ontology)
    {
      name: ontology.name,
      acronym: '',
      language: ontology.language.nil? ? '' : ontology.language.name,
      logic:  ontology.logic.nil? ? '' : ontology.logic.name,
      iri: ontology.iri,
      #url: repository_ontology_path(ontology.repository, ontology),
      url: "repositories/#{ontology.repository.to_param}/ontologies/#{ontology.to_param}",
      description: ontology.description
    }
  end

end
