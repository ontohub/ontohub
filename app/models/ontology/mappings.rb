module Ontology::Mappings
  extend ActiveSupport::Concern

  included do
    has_many :mappings,
      autosave: false,
      extend:   Methods
  end

  module Methods


    def iri_for_child(*args)
      proxy_association.owner.iri_for_child(*args)
    end

    def determine_mapping_type(typename)
      raise "mapping type missing" if typename.blank?
      kind = Mapping::KINDS_MAPPING[typename]
      if kind.nil?
        key = Mapping::KINDS_MAPPING.keys.find {|k| typename.include?(k) }
        kind = Mapping::KINDS_MAPPING[key]
      end
      if kind.nil?
        kind = Mapping::KINDS.find {|k| typename.downcase.include?(k) }
      end
      kind || Mapping::DEFAULT_LINK_KIND
    end

    def update_or_create_from_hash(hash, user, timestamp = Time.now)
      raise ArgumentError, 'No hash given.' unless hash.is_a? Hash
      # hash['name'] # maybe nil, in this case, we need to generate a name
      mapping_iri   = iri_for_child(hash['name'] || hash['linkid'])
      mapping_name  = hash['name']
      source_iri = hash['source_iri'] || iri_for_child(hash['source'])
      target_iri = hash['target_iri'] || iri_for_child(hash['target'])

      source = Ontology.find_with_iri(source_iri) || (raise ArgumentError,
        "source #{Settings.OMS} not found: #{source_iri}")
      target = Ontology.find_with_iri(target_iri) || (raise ArgumentError,
        "target #{Settings.OMS} not found: #{target_iri}")

      # mapping_type
      mapping_type = hash['type']
      kind = determine_mapping_type(mapping_type)

      # morphism
      gmorphism = hash['morphism']
      raise "gmorphism missing" if gmorphism.blank?
      gmorphism = 'http://purl.net/dol/translations/' + gmorphism unless gmorphism.include?('://')

      # finally, create or update the mapping
      mapping = find_or_initialize_by_iri(mapping_iri)
      mapping.attributes = {
        name:          mapping_name,
        source_id:     source.id,
        target_id:     target.id,
        kind:          kind,
        theorem:       mapping_type.include?("Thm"),
        proven:        mapping_type.include?("Proven"),
        local:         mapping_type.include?("Local"),
        inclusion:     mapping_type.include?("Inc"),
      }
      mapping.updated_at = timestamp
      mapping.save!
      mapping_version = LinkVersion.create(mapping: mapping,
                                        source: source.current_version,
                                        target: target.current_version)
      mapping.versions << mapping_version
      mapping.update_version!(to: mapping_version)

      # symbol mapping
      if hash["map"]
        source = Symbol.where(text: hash["map"].first["text"],ontology_id: mapping.source.id).first
        target = Symbol.where(text: hash["map"].second["text"], ontology_id: mapping.target.id).first
        symbol_mapping = EntityMapping.
          where(source_id: source, target_id: target, mapping_id: mapping).
          first_or_create!
      end
    end
  end
end
