class ProjectsController < InheritedResources::Base

  belongs_to :ontology, optional: true

  before_filter :check_read_permissions


  def create
    create! do |format|
      if parent
        parent.projects << resource
        parent.save
      end
      format.html { redirect_to [*resource_chain, :projects] }
    end
  end

  def update
    update! do |format|
      format.html { redirect_to [*resource_chain, :projects] }
    end
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to [*resource_chain, :projects] }
    end
  end


  private

  def check_read_permissions
    authorize! :show, parent.repository if parent.is_a? Ontology
  end
end
