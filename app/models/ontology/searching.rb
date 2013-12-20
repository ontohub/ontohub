module Ontology::Searching
  extend ActiveSupport::Concern

  included do
    searchable do
      text :name
      text :entities do
        names = Array.new
        entities.each do |symbol|
          names.push symbol.display_name if symbol.display_name
          names.push symbol.name if symbol.name
          names.push symbol.text if symbol.text
        end
        names
      end
      text :logic do
        logic.name if logic
      end
      integer :repository_id
    end
  end

  module ClassMethods
    def search_by_keywords_in_repository(keywords, page, repository)
      Ontology.search do
        keywords.each { |keyword| fulltext keyword }
        with(:repository_id, repository.id)
        paginate page: page, per_page: 20
      end
    end

    def search_by_keywords(keywords, page)
      Ontology.search do
        keywords.each { |keyword| fulltext keyword }
        paginate page: page, per_page: 20
      end
    end
  end

end
