class CommentsController < PolymorphicResource::Base

  belongs_to :ontology, :polymorphic => true

end
