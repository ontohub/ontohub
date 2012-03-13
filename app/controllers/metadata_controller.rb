class MetadataController < InheritedResources::Base
  belongs_to :ontology

  actions :index, :create, :update, :destroy

  def create
    create! { redirect_to ontology_metadata_path and return }
  end
end
