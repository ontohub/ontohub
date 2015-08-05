module Ontology::HetsOptions
  extend ActiveSupport::Concern

  EXTENSIONS_TO_INPUT_TYPES = {'.tptp' => 'tptp',
                               '.p' => 'tptp'}

  def hets_options
    Hets::HetsOptions.new(:'url-catalog' => repository.url_maps,
                          :'access-token' => repository.generate_access_token,
                          :'input-type' => EXTENSIONS_TO_INPUT_TYPES[file_extension])
  end
end
