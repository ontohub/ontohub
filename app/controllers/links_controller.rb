# 
# Controller for Links
# 
class LinksController < InheritedResources::Base
  respond_to :json, :xml
  has_pagination
  has_scope :search
  
  load_and_authorize_resource :except => [:index, :show]

  def index
    super do |format|
      format.html do
        @search = params[:search]
        @search = nil if @search.blank?
      end
    end
  end
  
  def new
    @version = build_resource.versions.build
  end
  
  def create
    @version = build_resource.versions.first
    @version.source = Ontology.find(params[:link][:source_id]).versions.current
    @version.target = Ontology.find(params[:link][:target_id]).versions.current
    super
  end
  
  def build_resource
    return @link if @link
    @link = Link.new params[:link]
  end
  
  def update_version
    @version = resource.versions.current.dup
    @version.version_number = @version.version_number + 1
    @version.save
    redirect_to edit_link_link_version_path(resource, @version)
  end
  
end