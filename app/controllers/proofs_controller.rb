class ProofsController < InheritedResources::Base
  defaults resource_class: Proof
  before_filter :check_write_permissions
  helper_method :ontology

  def new
    render template: 'proofs/new'
  end

  def create
    if resource.valid?
      resource.save!
      flash[:success] = t('proofs.create.starting_jobs')
      redirect_to(overview_url)
    else
      flash[:alert] = t('proofs.create.invalid_resource')
      redirect_to(action: :new, params: {proof: params[:proof]})
    end
  end

  protected

  def resource
    @resource ||= resource_class.new(params)
  end

  def ontology
    resource.ontology
  end

  def overview_url
    if resource.theorem?
      url_for([resource.proof_obligation, :proof_attempts])
    else
      url_for([resource.proof_obligation.ontology, :theorems])
    end
  end

  def check_write_permissions
    authorize! :write, ontology.repository
  end
end
