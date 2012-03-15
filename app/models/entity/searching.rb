module Entity::Searching
  extend ActiveSupport::Concern

  included do
    searchable do
      text    :text, :stored => true
      string  :kind
      integer :ontology_id
      string( :ontology_id_str) { |e| e.ontology_id.to_s }
    end
  end

end
