class Api::V1::ProofStatusesController < Api::V1::Base
  inherit_resources
  actions :index, :show

  def index
    super do |format|
      format.json do
        render json: collection,
          each_serializer: ProofStatusSerializer::Reference
      end
    end
  end
end
