module Ontology::CVertices
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :categories
    attr_accessible :parent_id
  end


  def create_categories 
    if self.logic.name != 'OWL2' then
      raise Exception.new('Error: No OWL2')
    end
    # Delete previous set of categories
    [ CVertex.all, CEdge.all ].flatten.each { |c| c.destroy }
    classes = self.entities.select { |e| e.kind == 'Class' }
    subclasses = self.sentences.select { |e| e.text.include?('SubClassOf')}
    classes.each do |c|
      CVertex.create!(:name => c.display_name || c.name)
    end

    subclasses.each do |s|
      c1,c2 = s.extract_class_names
      CEdge.create!(:child_id => CVertex.find_by_name(c1).id, :parent_id => CVertex.find_by_name(c2).id)
    end
  end

end
