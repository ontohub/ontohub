module OntologyVersion::Proving
  extend ActiveSupport::Concern

  def prove_options
    Hets::ProveOptions.new(:'url-catalog' => ontology.repository.url_maps,
                           ontology: ontology)
  end
end
