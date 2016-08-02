class OntologySerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      url_for(object)
    end
  end

  attributes :iri, :evaluation_state

  attributes :name, :acronym, :description, :documentation
  attributes :basepath, :file_extension

  has_one :logic, serializer: LogicSerializer::Reference
  has_one :repository, serializer: RepositorySerializer::Reference
  has_one :parent, serializer: OntologySerializer::Reference
  has_one :current_ontology_version,
    serializer: OntologyVersionSerializer::Reference
  has_many :license_models, each_serializer: LicenseModelSerializer::Reference
  has_one :formality_level,
    serializer: FormalityLevelSerializer::Reference
  has_one :ontology_type,
    serializer: OntologyTypeSerializer::Reference

  attributes :ontology_versions, :symbols, :sentences, :mappings

  def iri
    Reference.new(object).iri
  end

  def evaluation_state
    object.state
  end

  def current_ontology_version
    object.current_version
  end

  def ontology_versions
    url_for([object, :ontology_versions])
  end

  def symbols
    url_for([object, :symbols])
  end

  def sentences
    url_for([object, :sentences])
  end

  def mappings
    url_for([object, :mappings])
  end
end
