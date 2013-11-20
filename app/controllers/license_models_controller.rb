class LicenseModelsController < InheritedResources::Base
  belongs_to :ontology
  def index
    @ontology = Ontology.find(params[:ontology_id])
    @license_models = @ontology.license_models
  end
end
