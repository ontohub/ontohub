class Api::V1::ProverOutputsController < Api::V1::Base
  inherit_resources
  defaults singleton: true
  belongs_to :proof_attempt
  actions :show
end
