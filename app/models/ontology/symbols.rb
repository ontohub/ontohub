class Ontology
  module Symbols
    extend ActiveSupport::Concern

    module Methods
      def update_or_create_from_hash(hash, timestamp = Time.now)
        raise ArgumentError, 'No hash given.' unless hash.is_a? Hash

        e = where(text: hash['text']).first_or_initialize

        e.ontology   = @association.owner
        e.range      = hash['range']
        e.updated_at = timestamp

        unless hash['name'] || hash['kind']
          Rails.logger.warn(
            "Using work-around to determine symbol name and kind: #{e.inspect}")

          if e2 = Symbol.where(text: hash['text']).first
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

        e.iri = hash['iri']
        e.label = hash['label']

        sep = '//'
        locid_portion =
          if e.name.include?('://')
            Rack::Utils.escape_path(e.name)
          else
            e.name
          end

        if e.range.to_s.include?(':')
          # remove path from range
          # Examples/Reichel:28.9 -> 28.9
          e.range = e.range.split(':', 2).last
        end

        e.ontology.symbols << e if e.id.nil?
        e.save!

        LocId.where(
                       locid: "#{e.ontology.locid}#{sep}#{locid_portion}",
                       assorted_object_id: e.id,
                       assorted_object_type: e.class,).first_or_create!
        e
      end
    end

    def delete_edges
      %i[parent_id child_id].each do |key|
        EEdge.where(key => symbols.where(kind: 'Class')).delete_all
      end
    end

    def create_symbol_tree
      raise StandardError.new('Ontology is not OWL') unless owl?

      # Delete previous set of categories
      delete_edges
      subclasses =
        sentences.where("text LIKE '%SubClassOf%'").select do |sentence|
          sentence.text.split(' ').size == 4
        end
      transaction requires_new: true do
        subclasses.each do |s|
          c1, c2 = s.hierarchical_class_names

          unless c1 == 'Thing' || c2 == 'Thing'
            child_id = symbols.where('name = ? OR iri = ?', c1, c1).first.id
            parent_id = symbols.where('name = ? OR iri = ?', c2, c2).first.id

            EEdge.create! child_id: child_id, parent_id: parent_id
            if EEdge.where(child_id: child_id, parent_id: parent_id).first.nil?
              raise StandardError.new('Circle detected')
            end
          end
        end
      end
    end
  end
end
