#
# Controller for Languages
#
class LanguagesController < InheritedResources::Base

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

  def create
    @language.user = current_user
    super
  end

  def show
    super do |format|
      format.html do
        @mappings_from = resource.mappings_from
        @mappings_to = resource.mappings_to
        @serializations = resource.serializations
        @ontologies = resource.ontologies
        @relation_list ||= RelationList.new [resource, :supports],
          :model       => Support,
          :collection  => resource.supports,
          :association => :logic,
          :scope       => [Logic]
      end
    end
  end

end
