#
# Controller for Mappings
#
class MappingsController < InheritedResources::Base

  respond_to :json, :xml
  has_pagination
  has_scope :search
  belongs_to :ontology, optional: true
  load_and_authorize_resource except: [:index, :show]
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
    @version.source =
      Ontology.find(params[:mapping][:source_id]).current_version
    @version.target =
      Ontology.find(params[:mapping][:target_id]).current_version
    super
  end

  def update_version
    @version = resource.current_version.dup
    @version.version_number = @version.version_number + 1
    @version.save
    @version.ontology.update_version!(to: @version)
    redirect_to edit_mapping_link_version_path(resource, @version)
  end

  private

  def collection
    if params[:ontology_id]
      collection = Mapping.with_ontology_reference(params[:ontology_id])
    else
      collection = super
    end
    @mappings = collection = collection.
        joins(source: :logic).order('logics.name DESC')
    paginate_for(collection.select { |m| restrict_by_permission(m) })
  end

  def restrict_by_permission(mapping)
    can?(:show, mapping.source.repository) &&
    can?(:show, mapping.target.repository)
  end

  def build_resource
    @mapping ||= Mapping.new params[:mapping]
  end

  def check_read_permissions
    unless params[:action] == 'index'
      authorize! :show, resource.source.repository if resource.source
      authorize! :show, resource.target.repository if resource.target
    end
  end
end
