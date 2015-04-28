class ProverOutputsController < InheritedResources::Base
  defaults singleton: true
  belongs_to :proof_attempt
  actions :show
  helper_method :ontology, :theorem, :proof_attempt
  before_filter :check_read_permissions

  protected

  def proof_attempt
    @proof_attempt ||= ProofAttempt.find(params[:proof_attempt_id])
  end

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
