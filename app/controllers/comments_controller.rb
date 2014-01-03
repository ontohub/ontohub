class CommentsController < PolymorphicResource::Base

  belongs_to :ontology, :polymorphic => true
  before_filter :check_read_permissions

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end
end
