# 
# Lists sentences of an ontology
# 
class SentencesController < InheritedResources::Base

  belongs_to :ontology

  actions :index
  respond_to :json, :xml
  has_pagination

  before_filter :check_read_permissions

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end
end
