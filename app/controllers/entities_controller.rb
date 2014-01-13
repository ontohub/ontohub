#
# Lists entities of an ontology
#
class EntitiesController < InheritedResources::Base

  belongs_to :ontology
  before_filter :check_read_permissions

  actions :index
  has_scope :kind
  has_pagination
  respond_to :json, :xml

  def index
    ontology = Ontology.find params[:ontology_id]

    if ontology && (ontology.is?('OWL2') || ontology.is?('OWL'))
      begin
        entities = ontology.entities.where(kind: 'Class')
        @nodes = Entity.roots_of(*entities).first.children
      rescue
        @nodes = []
      end
      @hierarchy_exists = !@nodes.empty?
    end

    @page_selected = !! params[:page]

    index! do |format|
      format.html do
        unless collection.blank?
          first_entity = collection.first
          @show_name_column = !(first_entity.display_name or first_entity.text.include? first_entity.name)
        end
      end
    end
  end

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end
end
