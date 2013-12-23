class ProjectsController < InheritedResources::Base

  belongs_to :ontology

  before_filter :check_read_permissions


  def create
    create! do |format|
      format.html { redirect_to [@ontology.repository, @ontology, :projects] }
    end
  end

  def update
    update! do |format|
      format.html { redirect_to [@ontology.repository, @ontology, :projects] }
    end
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to [@ontology.repository, @ontology, :projects] }
    end
  end


  private

  def check_read_permissions
    authorize! :show, parent.repository if parent.is_a? Ontology
  end

  def begin_of_association_chain
    @ontology ||= Ontology.find(params[:ontology_id])
  end

end
