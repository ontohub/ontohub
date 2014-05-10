# Class for using the Tarjan algorithm to remove cycles in the entity trees.
class TarjanTree
  include TSort

  def initialize(ontology)
    @hashed_entities = Hash.new
    subclasses = inheritance_sentences ontology
    subclasses.each do |s|
      c1, c2 = s.hierarchical_class_names

      child = ontology.entities.where('name = ? OR iri = ?', c1, c1).first!.id
      parent = ontology.entities.where('name = ? OR iri = ?', c2, c2).first!.id
      if @hashed_entities[parent]
        @hashed_entities[parent] << child
      else
        @hashed_entities[parent] = [child]
      end
    end
    create_tree ontology
  end

  def tsort_each_node(&block)
    @hashed_entities.each_key(&block)
  end

  def tsort_each_child(node, &block)
    @hashed_entities[node].try(:each, &block)
  end

  # Get SubClassOf Strings without explicit Thing
  # Only sentences with 4 words are the right sentences for the Tree
  # so we have to ignore the other.
  def inheritance_sentences(ontology)
    ontology.sentences
      .where("text LIKE '%SubClassOf%' AND text NOT LIKE '%Thing%'")
      .select do |sentence|
        sentence.text.split(' ').size == 4
      end
  end

  def create_tree(ontology)
    create_groups ontology
    create_edges
  end

  def create_groups(ontology)
    groups = self.strongly_connected_components
    groups.each do |entity_group|
      entities = Entity.find(entity_group)
      name = determine_group_name(entities)
      EntityGroup.create!(ontology: ontology, entities: entities, name: name)
    end
  end

  def create_edges
    @hashed_entities.each do |parent, children|
      parent_group = Entity.find(parent).entity_group
      children.each do |child|
        child_group = Entity.find(child).entity_group
        unless parent_group == child_group
          EEdge.find_or_create_by_parent_id_and_child_id(parent_group.id, child_group.id)
        end
      end
    end
  end

  def determine_group_name(entities)
    entities.join(" ☰ ")
  end
end
