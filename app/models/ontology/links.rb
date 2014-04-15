module Ontology::Links
  extend ActiveSupport::Concern

  included do
    has_many :links,
      autosave: false,
      extend:   Methods
  end

  module Methods

    
    def iri_for_child(*args)
      proxy_association.owner.iri_for_child(*args)
    end
    
    def determine_link_type(typename)
      raise "link type missing" if typename.blank?
      kind = Link::KINDS_MAPPING[typename]
      if kind.nil?
        key = Link::KINDS_MAPPING.keys.find {|k| typename.include?(k) }
        kind = Link::KINDS_MAPPING[key]
      end
      if kind.nil?
        kind = Link::KINDS.find {|k| typename.downcase.include?(k) }
      end
      kind || Link::DEFAULT_LINK_KIND
    end

    def update_or_create_from_hash(hash, user, timestamp = Time.now)
      raise ArgumentError, 'No hash given.' unless hash.is_a? Hash
      # hash['name'] # maybe nil, in this case, we need to generate a name
      link_iri   = iri_for_child(hash['name'] || hash['linkid'])
      link_name  = hash['name']
      source_iri = hash['source_iri'] || iri_for_child(hash['source'])
      target_iri = hash['target_iri'] || iri_for_child(hash['target'])

      source = Ontology.find_with_iri(source_iri) || (raise ArgumentError, "source ontology not found: #{source_iri}")
      target = Ontology.find_with_iri(target_iri) || (raise ArgumentError, "target ontology not found: #{target_iri}")
      
      # linktype
      linktype = hash['type']
      kind = determine_link_type(linktype)
      
      # morphism
      gmorphism = hash['morphism']
      raise "gmorphism missing" if gmorphism.blank?
      gmorphism = 'http://purl.net/dol/translations/' + gmorphism unless gmorphism.include?('://')

      # finally, create or update the link
      link = find_or_initialize_by_iri(link_iri)
      link.attributes = {
        name:          link_name, 
        source_id:     source.id,
        target_id:     target.id,
        kind:          kind,
        theorem:       linktype.include?("Thm"),
        proven:        linktype.include?("Proven"),
        local:         linktype.include?("Local"),
        inclusion:     linktype.include?("Inc"),
      }
      link.updated_at = timestamp
      link.save!
      link.versions << LinkVersion.create(link: link,
                                          source: source.versions.current,
                                          target: target.versions.current)
                                                    
      # entity mapping
      if hash["map"]
        source = Entity.where(text: hash["map"].first["text"],ontology_id: link.source.id).first
        target = Entity.where(text: hash["map"].second["text"], ontology_id: link.target.id).first
        entity_mapping = EntityMapping.
          where(source_id: source, target_id: target, link_id: link).
          first_or_create!
      end
    end
  end
end
