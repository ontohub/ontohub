# 
# Controller for ontologies
# 
class OntologiesController < InheritedResources::Base

  has_pagination
  has_scope :search

  load_and_authorize_resource :except => [:index, :show]

  respond_to :json
  
  def index
    @search = params[:search]
    @search = nil if @search.blank?
  end
  
  def show
    @grouped_kinds = resource.entities.grouped_by_kind
  end

  def new
    @version = build_resource.versions.build
  end

  def create
    @version = build_resource.versions.first
    @version.user = current_user
    super
  end

end
