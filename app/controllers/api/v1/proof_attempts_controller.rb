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

  def used_axioms
    respond_to do |format|
      format.json do
        render json: resource.used_axioms,
               each_serializer: AxiomSerializer::Reference
      end
    end
  end

  def generated_axioms
    respond_to do |format|
      format.json do
        render json: resource.generated_axioms,
               each_serializer: GeneratedAxiomSerializer
      end
    end
  end

  def used_theorems
    respond_to do |format|
      format.json do
        render json: resource.used_theorems,
               each_serializer: TheoremSerializer::Reference
      end
    end
  end

  def prover_output
    respond_to do |format|
      format.json do
        render json: resource.prover_output
      end
    end
  end

  protected

  def collection
    super.order('number ASC')
  end
end
