module Entity::Searching
  extend ActiveSupport::Concern

  included do
    searchable do
      text :text, stored: true # necessary for highlighting
      text :prefix do
        prefixes = []
        (1 .. display_name.size).each { |length| prefixes.push display_name[0, length] } if display_name
        (1 .. name.size).each { |length| prefixes.push name[0, length] } if name
        (1 .. text.size).each { |length| prefixes.push text[0, length] } if text
        prefixes
      end

      string(:kind) { |symbol| symbol.kind.to_s.downcase }
      integer :ontology_id
      string(:ontology_id_str) { |symbol| symbol.ontology_id.to_s }
      integer(:repository_id) { |symbol| symbol.ontology.repository.id }
    end
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
