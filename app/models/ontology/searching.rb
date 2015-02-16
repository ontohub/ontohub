module Ontology::Searching
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mapping do
      indexes :name, type: 'string', analyzer: 'simple'
      indexes :description, analyzer: 'simple'
    end
  end
end
