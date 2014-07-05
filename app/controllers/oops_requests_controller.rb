class OopsRequestsController < ApplicationController
  respond_to :json

  before_filter :check_creatable, :only => :create

  def show
    raise ActiveRecord::RecordNotFound, 'Not Found' unless resource

    respond_with resource
  end

  def create
    respond_to do |format|
      ontology_version.create_oops_request!
      format.json do
        respond_with(*resource_chain, ontology_version, resource)
      end
      format.html do
        flash[:notice] = "Your request is send to OOPS!"
        redirect_to repository_ontology_path(*resource_chain)
      end
    end
  end

protected
  def ontology
    Ontology.find(params[:ontology_id])
  end

  def ontology_version
    ontology.versions.where(number: params[:ontology_version_id]).first!
  end

  def resource
    ontology_version.request
  end

  def check_creatable
    unless ontology_version.oops_request_creatable?
      head :forbidden
    end
  end

end
