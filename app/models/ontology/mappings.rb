class Ontology
  module Mappings
    extend ActiveSupport::Concern

    included do
      has_many :mappings,
        autosave: false,
        extend:   Methods
    end

    module Methods
      def locid_for_child(*args)
        proxy_association.owner.locid_for_child(*args)
      end

      def determine_mapping_type(typename)
        raise 'mapping type missing' if typename.blank?
        kind = Mapping::KINDS_MAPPING[typename]
        if kind.nil?
          key = Mapping::KINDS_MAPPING.keys.detect { |k| typename.include?(k) }
          kind = Mapping::KINDS_MAPPING[key]
        end
        if kind.nil?
          kind = Mapping::KINDS.detect { |k| typename.downcase.include?(k) }
        end
        kind || Mapping::DEFAULT_MAPPING_KIND
      end

      def determine_mapping_endpoint_iri(endpoint_iri, endpoint)
        return endpoint_iri if endpoint_iri
        absolute =
          begin
            URI(endpoint).absolute?
          rescue ArgumentError
            false
          end
        owner = proxy_association.owner
        if owner.distributed?
          locid_for_child(endpoint)
        elsif owner.locid.end_with?(endpoint)
          # It's a mapping to this single ontology - a locid for a child would
          # be wrong. The IRI must point to this single ontology:
          "#{Hostname.url_authority}#{owner.locid}"
        elsif absolute
          endpoint
        else
          # It's a mapping to a single ontology - a locid for a child would be
          # wrong. Guess that the endpoint is in the repository root:
          "#{Hostname.url_authority}/#{owner.repository.path}/#{endpoint}"
        end
      end

      def update_or_create_from_hash(hash, _user, timestamp = Time.now)
        raise ArgumentError, 'No hash given.' unless hash.is_a? Hash
        # hash['name'] # maybe nil, in this case, we need to generate a name
        mapping_iri   = locid_for_child(hash['name'] || hash['linkid'])
        mapping_name  = hash['name']
        source_iri = determine_mapping_endpoint_iri(hash['source_iri'], hash['source'])
        target_iri = determine_mapping_endpoint_iri(hash['target_iri'], hash['target'])

        source = Ontology.find_with_iri(source_iri) || (raise ArgumentError,
          "source #{Settings.OMS} not found: #{source_iri}")
        target = Ontology.find_with_iri(target_iri) || (raise ArgumentError,
          "target #{Settings.OMS} not found: #{target_iri}")

        # mapping_type
        mapping_type = hash['type']
        kind = determine_mapping_type(mapping_type)

        # morphism
        gmorphism = hash['morphism']
        raise 'gmorphism missing' if gmorphism.blank?
        unless gmorphism.include?('://')
          gmorphism = 'http://purl.net/dol/translations/' + gmorphism
        end

        # finally, create or update the mapping
        mapping = find_or_initialize_by_iri(mapping_iri)
        mapping.attributes = {
          name:          mapping_name,
          source_id:     source.id,
          target_id:     target.id,
          kind:          kind,
          theorem:       mapping_type.include?('Thm'),
          proven:        mapping_type.include?('Proven'),
          local:         mapping_type.include?('Local'),
          inclusion:     mapping_type.include?('Inc'),
        }
        mapping.linkid = hash['linkid']
        mapping.updated_at = timestamp

        mapping.save!
        mapping_version = MappingVersion.create(mapping: mapping,
                                                source: source.current_version,
                                                target: target.current_version)
        mapping.versions << mapping_version
        mapping.update_version!(to: mapping_version)

        # symbol mapping
        if hash['map']
          source = OntologyMember::Symbol.where(text: hash['map'].
            first['text'], ontology_id: mapping.source.id).first
          target = OntologyMember::Symbol.where(text: hash['map'].
            second['text'], ontology_id: mapping.target.id).first
          SymbolMapping.
            where(source_id: source, target_id: target, mapping_id: mapping).
            first_or_create!
        end
      end
    end
  end
end
