module Ontology::HetsOptions
  extend ActiveSupport::Concern

  # Hets has some trouble inferring those input types
  # by itself, so we give it a hint:
  EXTENSIONS_TO_INPUT_TYPES = {'.ax' => 'tptp', '.p' => 'tptp'}

  def hets_options
    Hets::HetsOptions.new(:'url-catalog' => repository.url_maps,
                          :'access-token' => repository.generate_access_token,
                          :'input-type' => input_type)
  end

  protected

  def input_type
    EXTENSIONS_TO_INPUT_TYPES[file_extension] || file_extension_without_dot
  end

  def file_extension_without_dot
    file_extension[1..-1] if file_extension
  end
end
