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
    if !self.is?('OWL')
      raise Exception.new('Error: No OWL')
    end

    # Delete previous set of categories
    delete_edges
    subclasses = self.sentences.where("text LIKE '%SubClassOf%'").select { |sentence| sentence.text.split(" ").size == 4 }
    transaction do
      subclasses.each do |s|
        c1, c2 = s.extract_class_names

        child_id = Entity.where(display_name: c1, ontology_id: s.ontology.id).first.id
        parent_id = Entity.where(display_name: c2, ontology_id: s.ontology.id).first.id

        EEdge.create! child_id: child_id, parent_id: parent_id
        if EEdge.where(child_id: child_id, parent_id: parent_id).first.nil?
          raise Error "Circle Detected"
        end
      end
    end
  end
end
