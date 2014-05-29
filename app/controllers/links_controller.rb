#
# Controller for Links
#
class LinksController < InheritedResources::Base

  respond_to :json, :xml
  has_pagination
  has_scope :search
  belongs_to :ontology, :optional => true
  load_and_authorize_resource :except => [:index, :show]
  before_filter :check_read_permissions

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
    @version.source = Ontology.find(params[:link][:source_id]).current_version
    @version.target = Ontology.find(params[:link][:target_id]).current_version
    super
  end

  def update_version
    @version = resource.current_version.dup
    @version.version_number = @version.version_number + 1
    @version.save
    @version.ontology.update_version!(to: @version)
    redirect_to edit_link_link_version_path(resource, @version)
  end


  private

  def collection
    if params[:ontology_id]
      onto = params[:ontology_id]
      @links = Link.where("ontology_id =#{onto} OR source_id = #{onto} OR target_id = #{onto}")
      collection = Kaminari.paginate_array(Link.where("ontology_id =#{onto} OR source_id = #{onto} OR target_id = #{onto}").
          select { |link| can?(:show, link.source.repository) && can?(:show, link.target.repository) }).page(params[:page])
    else
      Kaminari.paginate_array(super.select { |link| can?(:show, link.source.repository) && can?(:show, link.target.repository) }).page(params[:page])
    end
  end

  def build_resource
    @link ||= Link.new params[:link]
  end

  def check_read_permissions
    unless params[:action] == 'index'
      if resource.source
        authorize! :show, resource.source.repository
      end
      if resource.target
        authorize! :show, resource.target.repository
      end
    end
  end
end
