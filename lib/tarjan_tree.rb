# Class for using the Tarjan algorithm to remove cycles in the entity trees.
class TarjanTree
  include TSort
  attr_accessor :hashed_entities, :subclasses, :ontology

  def initialize(ontology)
    self.ontology = ontology
    self.hashed_entities = Hash.new
    self.subclasses = inheritance_sentences(ontology)
  end

  def calculate
    subclasses.each do |s|
      c1, c2 = s.hierarchical_class_names

      child_id = ontology.entities.where('name = ? OR iri = ?', c1, c1).first!.id
      parent_id = ontology.entities.where('name = ? OR iri = ?', c2, c2).first!.id

      hashed_entities[parent_id] ||= []
      hashed_entities[parent_id] << child_id
    end
    create_tree(ontology)
  end

  def self.for(ontology)
    tarjan_tree = new(ontology)
    ontology.entity_groups.destroy_all
    tarjan_tree.calculate
  end

  def tsort_each_node(&block)
    hashed_entities.each_key(&block)
  end

  def tsort_each_child(node, &block)
    hashed_entities[node].try(:each, &block)
  end

  # Get SubClassOf Strings without explicit Thing
  # Only sentences with 4 words are the right sentences for the Tree
  # so we have to ignore the other.
  def inheritance_sentences(ontology)
    ontology.sentences.where <<-SQL
      text NOT LIKE '%Thing%' AND
      text ~* '[^\s]+\s+[^\s]+\s+SubClassOf:+\s+[^\s]+'
    SQL
  end

  def create_tree(ontology)
    create_groups(ontology)
    create_edges
  end

  def create_groups(ontology)
    strongly_connected_components.each do |entity_ids|
      entities = Entity.find(entity_ids)
      name = group_name_for(entities)
      EntityGroup.create!(ontology: ontology, entities: entities, name: name)
    end
  end

  def create_edges
    hashed_entities.each do |parent_id, children|
      parent_group = Entity.find(parent_id).entity_group
      children.each do |child_id|
        child_group = Entity.find(child_id).entity_group
        if parent_group != child_group
          EEdge.where(parent_id: parent_group, child_id: child_group).first_or_create!
        end
      end
    end
  end

  def group_name_for(entities)
    entities.join(" ☰ ")
  end
end
