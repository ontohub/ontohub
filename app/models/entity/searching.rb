module Entity::Searching
  extend ActiveSupport::Concern
  
  included do
    searchable do
      text    :text,
        :stored => true # necessary for highlighting
      
      string( :kind) { |e| e.kind.to_s.downcase }
      integer :ontology_id
      string( :ontology_id_str) { |e| e.ontology_id.to_s }
    end
  end
  
  KIND_PATTERN = /kind:([\w\.-]+)/
  
  module ClassMethods
    def search_with_ontologies(term, max)
      term = term.dup
      
      # extract kind:<value>, if included
      if kind = KIND_PATTERN.match(term)
        kind = kind[1]
        term.sub!(KIND_PATTERN, '')
      end
      
      search :include => [:ontology] do
        
        # search for text
        fulltext term do
          highlight :text
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
