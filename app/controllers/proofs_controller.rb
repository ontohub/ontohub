class ProofsController < InheritedResources::Base
  defaults resource_class: Proof
  before_filter :check_write_permissions
  helper_method :ontology

  def new
    resource
    render template: 'proofs/new'
  end

  def create
    if resource.valid?
      resource.save!
      flash[:success] = t('proofs.create.starting_jobs')
      redirect_to(redirect_chain)
    else
      flash[:alert] = t('proofs.create.invalid_resource')
      redirect_to(action: :new)
    end
  end

  protected

  def resource
    @resource ||= resource_class.new(params)
  end

  def ontology
    resource.ontology
  end

  def redirect_chain
    @redirect_chain = resource_chain
    if resource.theorem?
      @redirect_chain << resource.proof_obligation
    else
      @redirect_chain << :theorems
    end
  end

  def check_write_permissions
    authorize! :write, ontology.repository
  end
end
