module Ontology::Searching
  extend ActiveSupport::Concern

  included do
    searchable do
      text :name
      text :entities do
        entities.map { |symbol| symbol.text }
      end
      text :logic do
        logic.name if logic
      end
      integer :repository_id
    end
  end

  module ClassMethods
    def search_by_keyword_in_repository(keyword, repository)
      search = Ontology.search do
        fulltext keyword
        with(:repository_id, repository.id)
      end
      search.results
    end

    def search_by_keyword(keyword)
      search = Ontology.search do
        fulltext keyword
      end
      search.results
    end
  end

end
