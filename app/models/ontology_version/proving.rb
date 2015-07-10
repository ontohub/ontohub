module OntologyVersion::Proving
  extend ActiveSupport::Concern

  def prove_options
    repo = ontology.repository
    Hets::ProveOptions.new(:'url-catalog' => repo.url_maps,
                           :'access-token' => repo.generate_access_token,
                           ontology: ontology)
  end
end
