class Api::V1::MappingsController < Api::V1::Base
  inherit_resources
  belongs_to :ontology

  actions :index, :show

  def index
    super do |format|
      format.json do
        render json: collection,
          each_serializer: MappingSerializer::Reference
      end
    end
  end
end
