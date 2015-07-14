class Api::V1::ProofAttemptConfigurationsController < Api::V1::Base
  inherit_resources
  belongs_to :ontology

  actions :index, :show

  def index
    super do |format|
      format.json do
        render json: collection,
          each_serializer: ProofAttemptConfigurationSerializer::Reference
      end
    end
  end

  def selected_axioms
    respond_to do |format|
      format.json do
        render json: resource.axioms,
               each_serializer: AxiomSerializer::Reference
      end
    end
  end

  def selected_theorems
    respond_to do |format|
      format.json do
        render json: [resource.proof_attempt.theorem],
               each_serializer: TheoremSerializer::Reference
      end
    end
  end
end
