class Api::V1::SymbolsController < Api::V1::Base
  inherit_resources
  defaults resource_class: OntologyMember::Symbol

  belongs_to :ontology do
    belongs_to :sentence, optional: true
  end

  actions :index, :show

  def index
    super do |format|
      format.json do
        render json: collection,
          each_serializer: OntologyMember::SymbolSerializer::Reference
      end
    end
  end
end
