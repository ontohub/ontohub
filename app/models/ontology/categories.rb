module Ontology::Categories
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :categories
    attr_accessible :parent_id, :category_ids
  end


  def create_categories 
    if !self.is?('OWL')
      raise Exception.new('Error: No OWL')
    end
    # Delete previous set of categories
    [ Category.all, CEdge.all ].flatten.each { |c| c.destroy }
    classes = self.entities.select { |e| e.kind == 'Class' }
    subclasses = self.sentences.select { |e| e.text.include?('SubClassOf')}
    classes.each do |c|
      Category.create!(:name => c.display_name || c.name)
    end

    subclasses.each do |s|
      c1,c2 = s.extract_class_names
      CEdge.create!(:child_id => Category.find_by_name(c1).id, :parent_id => Category.find_by_name(c2).id)
    end
  end

end
