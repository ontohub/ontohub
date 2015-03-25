class Api::V1::ProofAttemptsController < Api::V1::Base
  inherit_resources
  belongs_to :theorem

  actions :index, :show

  def index
    super do |format|
      format.json do
        render json: collection,
          each_serializer: ProofAttemptSerializer::Reference
      end
    end
  end

  protected

  def collection
    super.order('number ASC')
  end
end
