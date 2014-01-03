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
    classes.each { |c| categorify(c) }

    subclasses.each do |s|
      c1,c2 = s.hierarchical_class_names
      e1 = self.entities.where('name = ? OR iri = ?', c1, c1).first
      e2 = self.entities.where('name = ? OR iri = ?', c2, c2).first
      CEdge.create!(:child_id => categorify(e1).id, :parent_id => categorify(e2).id)
    end
  end

  protected
  def categorify(entity)
    return if entity.kind != 'Class'
    Category.where(name: entity.display_name || entity.name).
      first_or_create!
  end

end
