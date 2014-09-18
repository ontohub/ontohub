module ParsingCallback::OWL

  IDENTIFIERS = %w(OWL OWL2)

  def self.defined_for?(logic_name)
    IDENTIFIERS.include?(logic_name)
  end

  class Callback < ParsingCallback::GenericCallback

    def pre_axiom(hash)
      if is_annotation_sentence?(hash)
        m = hash['text'].match(%r{
          Class:\s+(?<entity_name>.+?) # Entity/Symbol Identifier
          \s+
          Annotations:\s+(?<annotation_type>label|comment) # the type of annotation
          \s+
          "(?<annotation>.*)" # The actual annotation
          \s*
          (?<additionals>[^\s].*) # optional, e.g. a language tag like @pt}xm)
        if m
          entity = Entity.where(name: m['entity_name']).first
          case m['annotation_type']
          when 'label'
            entity.label = m['annotation']
          when 'comment'
            entity.comment = m['annotation']
          end if entity
          entity.save
        end
        false
      else
        true
      end
    end

    def axiom(hash, axiom)
    end

    def ontology_end(hash, ontology)
      begin
        TarjanTree.for(ontology)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.warn "Could not create entity tree for: #{ontology.name} (#{ontology.id}) caused #{e}"
      end
    end

    private
    def is_annotation_sentence?(axiom_hash)
      axiom_hash['symbol_hashes'].each do |hash|
        return true if hash['kind'] == 'AnnotationProperty'
      end
      false
    end

  end

end
