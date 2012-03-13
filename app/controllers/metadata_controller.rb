class MetadataController < PolymorphicResource::Base
  belongs_to :ontology, :polymorphic => true
end
