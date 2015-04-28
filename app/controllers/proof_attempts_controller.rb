class ProofAttemptsController < InheritedResources::Base
  belongs_to :theorem
  actions :index, :show
  helper_method :ontology, :theorem
  before_filter :check_read_permissions

  protected

  def theorem
    @theorem ||= Theorem.find(params[:theorem_id])
  end

  def ontology
    @ontology ||= Ontology.find(params[:ontology_id])
  end

  def check_read_permissions
    authorize! :show, ontology.repository
  end
end
