class OntologySerializer < ApplicationSerializer
  class Reference < ApplicationSerializer
    attributes :iri
    attributes :name

    def iri
      qualified_locid_for(object)
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
    qualified_locid_for(object, :ontology_versions)
  end

  def symbols
    qualified_locid_for(object, :symbols)
  end

  def sentences
    qualified_locid_for(object, :sentences)
  end

  def mappings
    qualified_locid_for(object, :mappings)
  end
end
