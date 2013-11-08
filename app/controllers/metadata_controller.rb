# 
# Lists, adds and removes Metadatabe of its parent object
# 
class MetadataController < PolymorphicResource::Base

  belongs_to :ontology, :polymorphic => true

end
