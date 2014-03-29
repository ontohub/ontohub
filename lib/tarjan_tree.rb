#Class for using the Tarjan algorithm to remove cycles in the entity trees.

class TarjanTree
  include TSort

  def initialize ontology
    @hashed_entities = Hash.new
    subclasses = inheritance_sentences ontology
    subclasses.each do |s|
      c1, c2 = s.hierarchical_class_names
    
        child_id = ontology.entities.where('name = ? OR iri = ?', c1, c1).first.id
        parent_id = ontology.entities.where('name = ? OR iri = ?', c2, c2).first.id
        if @hashed_entities[parent_id]
          @hashed_entities[parent_id] << child_id
        else
          @hashed_entities[parent_id] = [child_id]
      end
    end
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
end
