require 'json'

class OntologyBeanListFactory

  def initialize()
    @beanList = []
  end

  def addSmallBean(ontology)
    bean = makeSmallBean(ontology)
    @beanList.push(bean)
  end

  def makeSmallBean(ontology)
    return {
      name: ontology.name,
      acronym: ontology.acronym,
      language: ontology.language.name,
      logic: ontology.current_version.logic.name,
      iri: ontology.iri,
      url: ontology.iri,
      acronym: ontology.acronym,
      description: ontology.description,
    }
  end

  def getBeanList()
    return @beanList
  end

end
