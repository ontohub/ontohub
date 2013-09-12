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
      source_iri = iri_for_child(hash['source'])
      target_iri = iri_for_child(hash['target'])
      
      source = Ontology.find_by_iri(source_iri) || (raise ArgumentError, "source ontology not found: #{source_iri}")
      target = Ontology.find_by_iri(target_iri) || (raise ArgumentError, "target ontology not found: #{target_iri}")
      
      # linktype
      linktype = hash['type']
      raise "link type missing" if linktype.blank?
      kind   = Link::KINDS.find {|k| linktype.downcase.include?(k) }
      kind ||= Link::KIND_DEFAULT
      
      # morphism
      gmorphism = hash['morphism']
      raise "gmorphism missing" if gmorphism.blank?
      gmorphism = 'http://purl.net/dol/translations/' + gmorphism unless gmorphism.include?('://')
      
      # logic mapping
      if source.logic and target.logic
        logic_mapping   = LogicMapping.find_by_iri gmorphism
        logic_mapping ||= LogicMapping.create! \
          source: source.logic,
          target: target.logic,
          iri: link_iri,
          user: user
      end
      
      # finally, create or update the link
      link = find_or_initialize_by_iri(link_iri)
      link.attributes = {
        source:        source,
        target:        target,
        kind:          kind,
        theorem:       linktype.include?("Thm"),
        proven:        linktype.include?("Proven"),
        local:         linktype.include?("Local"),
        inclusion:     linktype.include?("Inc"),
        logic_mapping: logic_mapping
      }
      link.updated_at = timestamp
      link.save!
    end
  end
end
