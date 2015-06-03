#
# Lists, adds and removes Metadatabe of its parent object
#
class MetadataController < PolymorphicResource::Base

  belongs_to :ontology, :polymorphic => true

  def index
    redirect_to locid_for(resource_chain.last, :projects)
  end

  before_filter :check_read_permissions

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end
end
