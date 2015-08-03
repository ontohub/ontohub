module Ontology::HetsOptions
  extend ActiveSupport::Concern

  def hets_options
    Hets::HetsOptions.new(:'url-catalog' => repository.url_maps,
                          :'access-token' => repository.generate_access_token)
  end
end
