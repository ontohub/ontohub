class ProofAttemptsController < InheritedResources::Base
  actions :show
  helper_method :ontology
  before_filter :check_read_permissions

  protected

  def ontology
    @ontology ||= Ontology.find(params[:ontology_id])
  end

  def check_read_permissions
    authorize! :show, ontology.repository
  end
end
