# The Proof class is not supposed to be stored in the database. Its purpose is
# to allow for an easy way to create proving commands in the RESTful manner.
# It is called Proof to comply with the ProofsController which in turn gets
# called on */proofs routes.
class Proof < FakeRecord
  class ProversValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      not_provers = value.reject { |id| Prover.where(id: id).any? }
      if not_provers.any?
        record.errors.add attribute, "#{not_provers} are not provers"
      end
    end
  end

  attr_reader :proof_obligation, :provers, :ontology

  validates :provers, provers: true

  def initialize(opts)
    opts[:proof] ||= {}
    opts[:proof][:provers] ||= []

    @ontology = Ontology.find(opts[:ontology_id])
    # HACK: remove the empty string from params
    # Rails 4.2 introduces the html form option :include_hidden
    @provers = opts[:proof][:provers].select(&:present?).map(&:to_i)
    @proof_obligation = proof_initialize_obligaion(opts)
  end

  def save!
    ontology_version.update_state! :pending
    CollectiveProofAttemptWorker.perform_async(proof_obligation.class.to_s,
                                               proof_obligation.id,
                                               provers)
  end

  def theorem?
    proof_obligation.is_a?(Theorem)
  end

  def to_s
    proof_obligation.to_s
  end

  protected

  def proof_initialize_obligaion(opts)
    @proof_obligation ||=
      if opts[:theorem_id]
        Theorem.find(opts[:theorem_id])
      else
        ontology_version
      end
  end

  def ontology_version
    @ontology_version ||= ontology.current_version
  end
end
