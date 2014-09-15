module Ontology::Searching
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mapping do
      indexes :name, type: 'string', :analyzer => 'snowball'
      indexes :description, :analyzer => 'snowball'
    end
  end
  end

end
