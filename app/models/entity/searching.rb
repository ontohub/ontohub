module Entity::Searching
  extend ActiveSupport::Concern

  included do

  end

  KIND_PATTERN = /kind:([\w\.-]+)/

  module ClassMethods
    def collect_keywords(prefix, repository)
      s = search do
        fulltext prefix do
          fields :prefix
        end
        with :repository_id, repository.id
        paginate page: 1, per_page: 5
      end
      s.results
    end

    def search_with_ontologies(name, max)
      name = name.dup

      # extract kind:<value>, if included
      if kind = KIND_PATTERN.match(term)
        kind = kind[1]
        term.sub!(KIND_PATTERN, '')
      end

      search :include => [:ontology] do

        # search for text
        fulltext term do
          highlight :text
          fields(:text)
        end

        # search for kind
        with :kind, kind.downcase if kind

        # group by ontology
        group :ontology_id_str do
          limit 10
        end

        # limit result
        paginate :per_page => max
      end
    end
  end

end
