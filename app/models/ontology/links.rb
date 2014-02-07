module Ontology::Links
  extend ActiveSupport::Concern

  included do
    has_many :links, :extend => Methods
  end

  module Methods
    
    def iri_for_child(*args)
      proxy_association.owner.iri_for_child(*args)
    end
    
    def update_or_create_from_hash(hash, user, timestamp = Time.now)
      raise ArgumentError, 'No hash given.' unless hash.is_a? Hash
      # hash['name'] # maybe nil, in this case, we need to generate a name
      link_iri   = iri_for_child(hash['name'] || hash['linkid'])
      link_name  = hash['name']
      source_iri = iri_for_child(hash['source'])
      target_iri = iri_for_child(hash['target'])
      
      source = Ontology.find_with_iri(source_iri) || (raise ArgumentError, "source ontology not found: #{source_iri}")
      target = Ontology.find_with_iri(target_iri) || (raise ArgumentError, "target ontology not found: #{target_iri}")
      Rails.logger.warn("source: #{source.inspect}")
      Rails.logger.warn("target: #{target.inspect}")
      
      # linktype
      linktype = hash['type']
      raise "link type missing" if linktype.blank?
      kind   = Link::KINDS.find {|k| linktype.downcase.include?(k) }
      if linktype.include?("Thm")
        kind ||= "view"
      else
        kind ||= "import"
      end
      
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
        entity_mapping = EntityMapping.first_or_initialize(source: source, target: target, link: link)
        entity_mapping.save!
      end
    end
  end
end
