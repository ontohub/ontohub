# 
# Lists, adds and removes Metadatabe of its parent object
# 
class MetadataController < PolymorphicResource::Base

  belongs_to :ontology, :polymorphic => true
  
  def index
    redirect_to repository_ontology_projects_path
  end

end
