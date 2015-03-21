module OntologyVersion::Proving
  extend ActiveSupport::Concern

  def prepared_prove_options(prove_options = nil)
    prove_options ||= Hets::ProveOptions.new
    # If the prove_options have gone through the async_prove call, they are now
    # a Hash and need to be restored as a ProveOptions object.
    if prove_options.is_a?(Hash)
      prove_options = Hets::ProveOptions.from_hash(prove_options)
    end
    prove_options.add(:'url-catalog' => ontology.repository.url_maps,
                      ontology: ontology)
    prove_options
  end
end
