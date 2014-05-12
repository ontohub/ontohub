#
# Permissions list administration of a team, only accessible by ontology owners
#
class Teams::PermissionsController < InheritedResources::Base

  before_filter :authorize_parent

  belongs_to :team
  respond_to :json, :xml
  actions :index

  has_pagination

  protected

  def authorize_parent
    authorize! :show, parent
  end

end
