class Api::V1::ChildrenController < Api::V1::Base
  inherit_resources
  belongs_to :ontology

  actions :index

  private
  def default_serializer_options
    {each_serializer: OntologySerializer::Reference}
  end
end
