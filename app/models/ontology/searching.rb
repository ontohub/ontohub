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
    def search_by_keywords_in_repository(keywords, page, repository)
      search = Ontology.search do
        fulltext keywords[0].downcase
      end
      search.results
    end

    def search_by_keywords(keywords, page)
      Ontology.search do
        fulltext keywords[0]
        paginate page: page
      end
    end
  end

end
