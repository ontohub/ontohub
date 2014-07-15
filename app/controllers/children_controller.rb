#
# Lists entities of an ontology
#
class ChildrenController < InheritedResources::Base

  belongs_to :ontology

  actions :index
  respond_to :json, :xml

  before_filter :check_read_permissions

  def check_read_permissions
    authorize! :show, parent.repository
  end
end
