class TheoremsController < InheritedResources::Base
  belongs_to :ontology

  actions :index, :show
  respond_to :json, :xml
  has_pagination

  before_filter :check_read_permissions

  protected

  def ontology
    @ontology ||= Ontology.find(params[:ontology_id])
  end

  def check_read_permissions
    authorize! :show, parent.repository
  end
end
