class ProveController < ApplicationController
  before_filter :check_write_permissions

  def create
    if ontology.unproven_theorems.present?
      ontology.current_version.async_prove
      flash[:success] = t('prove.create.starting_jobs')
    else
      flash[:notice] = t('prove.create.nothing_to_do')
    end
    redirect_to([ontology.repository, ontology, :theorems])
  end

  protected

  def ontology
    @ontology ||= Ontology.find(params[:ontology_id])
  end

  def check_write_permissions
    authorize! :write, ontology.repository
  end
end
