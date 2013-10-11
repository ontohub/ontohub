require 'json'

class OntologyBeanListFactory

  def initialize()
    @beanList = []
  end

  def addSmallBean(ontology)
    if (@beanList.size() < 50)
      bean = makeSmallBean(ontology)
      @beanList.push(bean)
    end
  end

  def makeSmallBean(ontology)
    return {
      name: ontology.name,
      acronym: "",
      language: ontology.language.nil? ? "" : ontology.language.name,
      logic:  ontology.logic.nil? ? "" : ontology.logic.name,
      iri: ontology.iri,
      #url: repository_ontology_path(ontology.repository, ontology),
      url: "repositories/#{ontology.repository.to_param}/ontologies/#{ontology.to_param}",
      description: ontology.description,
    }
  end

  def getBeanList()
    return @beanList
  end

end
