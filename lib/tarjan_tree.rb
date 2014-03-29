#Class for using the Tarjan algorithm to remove cycles in the entity trees.

class TarjanTree
  include TSort

  def initialize ontology
    @hashed_entities = Hash.new
    subclasses = inheritance_sentences ontology
    subclasses.each do |s|
      c1, c2 = s.hierarchical_class_names
    
        child = ontology.entities.where('name = ? OR iri = ?', c1, c1).first.id
        parent = ontology.entities.where('name = ? OR iri = ?', c2, c2).first.id
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
    @hashed_entities[node].each(&block) if @hashed_entities[node]
  end
  
  # Get SubClassOf Strings without explicit Thing
   def inheritance_sentences ontology
     ontology.sentences
       .where("text LIKE '%SubClassOf%' AND text NOT LIKE '%Thing%'")
       .select do |sentence|
         sentence.text.split(' ').size == 4
       end
   end
   
   def create_tree ontology
     create_groups ontology
     create_edges
   end
   
   def create_groups ontology
     groups = self.strongly_connected_components
     groups.each do |entity_group|
       entities = Entity.where(id: entity_group)
       name = determine_group_name(entities)
       EntityGroup.create!(ontology: ontology, entities: entities, name: name)
     end
   end
   
   def create_edges
     @hashed_entities.each do |parent, childs|
       parent_group = Entity.find(parent).entity_group
       childs.each do |child|
         child_group = Entity.find(child).entity_group
         unless parent_group == child_group
           EEdge.find_or_create_by_parent_id_and_child_id(parent_group.id, child_group.id)
         end
       end
     end
   end
   
   def determine_group_name entities
     name = ""
     entities.each_with_index do |entity, i|
       if entity == entities.last
         name += "#{entity}"
       else
         name += "#{entity} ☰ "
       end
    end
    name
   end
   
end
