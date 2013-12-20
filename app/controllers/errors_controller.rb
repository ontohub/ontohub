class ErrorsController < InheritedResources::Base
  belongs_to :repository, finder: :find_by_path!
  actions :index
  before_filter :index, :check_read_permissions

  def index
    ontos = parent.ontologies.without_parent
    @orphans = ontos.select{|o| o.versions.empty? }
    @failed_versions = parent.failed_ontology_versions
  end

  protected

  def check_read_permissions
    authorize! :show, parent
  end
    

end
