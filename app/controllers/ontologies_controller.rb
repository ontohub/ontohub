# 
# Controller for ontologies
# 
class OntologiesController < InheritedResources::Base

  respond_to :json, :xml
  has_pagination
  has_scope :search

  load_and_authorize_resource :except => [:index, :show]

  respond_to :json

  def index
    super do |format|
      format.html do
        @search = params[:search]
        @search = nil if @search.blank?
      end
    end
  end

  def show
    show! { @grouped_kinds = resource.entities.grouped_by_kind }
  end

  def new
    @ontology_version = build_resource.ontology_versions.build
  end

  def create
    @version = build_resource.versions.first
    @version.user = current_user
    super
  end

end
