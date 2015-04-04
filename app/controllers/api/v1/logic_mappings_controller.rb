class Api::V1::LogicMappingsController < Api::V1::Base
  inherit_resources
  actions :index, :show

  def index
    super do |format|
      format.json do
        render json: collection,
          each_serializer: LogicMappingSerializer::Reference
      end
    end
  end
end
