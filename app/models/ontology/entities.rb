module Ontology::Entities
  extend ActiveSupport::Concern

  included do
    has_many :entities,
      autosave: false,
      extend:   Methods
  end

  module Methods
    def update_or_create_from_hash(hash, timestamp = Time.now)
      raise ArgumentError, 'No hash given.' unless hash.is_a? Hash

      e = where(text: hash['text']).first_or_initialize

      e.ontology   = @association.owner
      e.range      = hash['range']
      e.updated_at = timestamp

      unless hash['name'] || hash['kind']
        Rails.logger.warn "Using work-around to determine entity name and kind: #{e.inspect}"

        if e2 = Entity.where(text: hash['text']).first
          e.name = e2.name
          e.kind = e2.kind
        else
          e.name = e.text
          e.kind = 'Undefined'
        end
      else
        e.name = hash['name']
        e.kind = hash['kind']
      end

      if e.range.to_s.include?(':')
        # remove path from range
        # Examples/Reichel:28.9 -> 28.9
        e.range = e.range.split(':', 2).last
      end

      e.save!
    end
  end

  def delete_edges
    %i[parent_id child_id].each do |key|
      EEdge.where(key => self.entities.where(kind: 'Class')).delete_all
    end
  end

  def create_entity_tree
    raise StandardError.new('Ontology is not OWL') unless self.owl?

    # Delete previous set of categories
    delete_edges
    subclasses = self.sentences.where("text LIKE '%SubClassOf%'").select { |sentence| sentence.text.split(" ").size == 4 }
    transaction requires_new: true do
      subclasses.each do |s|
        c1, c2 = s.hierarchical_class_names

        unless c1 == "Thing" || c2 == "Thing"
          child_id = self.entities.where('name = ? OR iri = ?', c1, c1).first.id
          parent_id = self.entities.where('name = ? OR iri = ?', c2, c2).first.id

          EEdge.create! child_id: child_id, parent_id: parent_id
          if EEdge.where(child_id: child_id, parent_id: parent_id).first.nil?
            raise StandardError.new('Circle detected')
          end
        end
      end
    end
  end

end
