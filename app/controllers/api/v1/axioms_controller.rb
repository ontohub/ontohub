class Api::V1::AxiomsController < Api::V1::Base
  inherit_resources
  belongs_to :ontology

  actions :index, :show

  def index
    super do |format|
      format.json do
        render json: collection,
          each_serializer: AxiomSerializer::Reference
      end
    end
  end
end
