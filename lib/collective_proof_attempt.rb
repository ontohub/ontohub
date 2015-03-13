class CollectiveProofAttempt
  attr_accessor :resource, :provers, :prove_options_list

  # Resource can be a Theorem or an OntologyVersion.
  # We call prove for every possible options combination on the resource.
  # The provers can be either Prover objects, IDs or names.
  def initialize(resource, provers)
    self.resource = resource
    initialize_provers(provers)

    self.prove_options_list = self.provers.map do |prover|
      Hets::ProveOptions.new(prover: prover)
    end
  end

  def run
    ontology_version.update_state! :processing
    ontology_version.do_or_set_failed do
      prove_options_list.each { |opts| resource.prove(opts) }
      ontology_version.update_state! :done
    end
  end

  protected

  def initialize_provers(provers)
    self.provers = provers.map do |prover|
      prover = prover.to_i if prover.is_a?(String) && prover.match(/\A\d+\z/)
      if prover.is_a?(Fixnum)
        Prover.find(prover)
      else
        prover
      end
    end
    self.provers.compact!

    self.provers = [nil] if self.provers.blank?
  end

  def ontology_version
    @ontology_version ||=
      if resource.is_a?(Theorem)
        resource.ontology.current_version
      else
        resource
      end
  end
end
