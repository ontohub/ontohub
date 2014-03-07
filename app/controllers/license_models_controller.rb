class LicenseModelsController < InheritedResources::Base

  belongs_to :ontology, optional: true
  before_filter :check_read_permissions
  load_and_authorize_resource

  def create
    create! do |success, failure|
      if parent
        parent.license_models << resource
        parent.save
      end
      success.html { redirect_to [*resource_chain, :license_models] }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to [*resource_chain, :license_models] }
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to [*resource_chain, :license_models] }
    end
  end


  private

  def check_read_permissions
    authorize! :show, parent.repository if parent.is_a? Ontology
  end
end
