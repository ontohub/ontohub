# Class for using the Tarjan algorithm to remove cycles in the symbol trees.
class TarjanTree
  include TSort
  attr_accessor :hashed_symbols, :subclasses, :ontology, :symbols
  attr_accessor :subclass_symbols

  def initialize(ontology)
    self.ontology = ontology
    self.hashed_symbols = Hash.new
    self.symbols = ontology.symbols
    self.subclass_symbols = []
    self.subclasses = inheritance_sentences(ontology)
  end

  def calculate
    subclasses.each do |s|
      c1, c2 = s.hierarchical_class_names
      child = ontology.symbols.where('name = ? OR iri = ?', c1, c1).first!
      parent = ontology.symbols.where('name = ? OR iri = ?', c2, c2).first!
      subclass_symbols << child
      subclass_symbols << parent
      hashed_symbols[parent.id] ||= []
      hashed_symbols[parent.id] << child.id
    end
    subclass_symbols.uniq!
    create_tree(ontology)
  end

  def self.for(ontology)
    tarjan_tree = new(ontology)
    ontology.symbol_groups.destroy_all
    tarjan_tree.calculate
  end

  def tsort_each_node(&block)
    hashed_symbols.each_key(&block)
  end

  def tsort_each_child(node, &block)
    hashed_symbols[node].try(:each, &block)
  end

  # Get SubClassOf Strings without explicit Thing
  # Only sentences with 4 words are the right sentences for the Tree
  # so we have to ignore the other.
  def inheritance_sentences(ontology)
    ontology.sentences.original.where <<-SQL
      text NOT LIKE '%Thing%' AND
      text ~* '[^\s]+\s+[^\s]+\s+SubClassOf:+\s+[^\s]+$'
    SQL
  end

  def create_tree(ontology)
    create_groups(ontology)
    create_edges
  end

  def create_groups(ontology)
    symbols = self.symbols - subclass_symbols
    strongly_connected_components.each do |symbol_ids|
      connected_symbols = OntologyMember::Symbol.find(symbol_ids)
      name = group_name_for(syms)
      SymbolGroup.create!(ontology: ontology,
                          symbols: connected_symbols,
                          name: name,
                         )
    end
    symbols.each do |symbol|
      name = group_name_for([symbol])
      SymbolGroup.create!(ontology: ontology, symbols: [symbol], name: name)
    end
  end

  def create_edges
    hashed_symbols.each do |parent_id, children|
      parent_group = OntologyMember::Symbol.find(parent_id).symbol_group
      children.each do |child_id|
        child_group = OntologyMember::Symbol.find(child_id).symbol_group
        if parent_group != child_group
          EEdge.where(parent_id: parent_group, child_id: child_group).first_or_create!
        end
      end
    end
  end

  def group_name_for(symbols)
    symbols.join(" ☰ ")
  end
end
