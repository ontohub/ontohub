class Api::V1::TheoremsController < Api::V1::Base
  inherit_resources
  belongs_to :ontology

  actions :index, :show

  def index
    super do |format|
      format.json do
        render json: collection,
          each_serializer: TheoremSerializer::Reference
      end
    end
  end
end
