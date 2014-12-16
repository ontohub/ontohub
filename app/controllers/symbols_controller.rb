#
# Lists symbols of an ontology
#
class SymbolsController < InheritedResources::Base

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
        symbols = ontology.symbol_groups
        @nodes = SymbolGroup.roots_of(*symbols)
      rescue
        @nodes = []
      end
      @hierarchy_exists = !@nodes.empty?
    end

    @page_selected = !! params[:page]

    index! do |format|
      format.html do
        unless collection.blank?
          first_symbol = collection.first
          @show_name_column = !(first_symbol.display_name or first_symbol.text.include? first_symbol.name)
        end
      end
    end
  end

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end
end
