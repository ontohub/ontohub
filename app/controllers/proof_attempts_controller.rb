class ProofAttemptsController < InheritedResources::Base
  belongs_to :theorem
  actions :index, :show
  helper_method :ontology, :theorem
  before_filter :check_read_permissions

  def retry_failed
    check_write_permissions
    resource.retry_failed
    redirect_to url_for(resource)
  end

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

  def check_write_permissions
    authorize! :write, ontology.repository
  end
end
