module Ontology::Categories
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :categories
    attr_accessible :parent_id, :category_ids
  end


  def create_categories 
    raise 'Error: No OWL' unless self.is? 'OWL'

    # Delete previous set of categories.
    [Category, CEdge].map(&:destroy_all)

    classes = self.entities.select { |e| e.kind == 'Class' }
    classes.map! { |c| categorify(c) }

    subclasses = self.sentences.select { |e| e.text.include?('SubClassOf')}
    subclasses.each do |s|
      c1, c2 = s.hierarchical_class_names

      e1 = self.entities.where('name = ? OR iri = ?', c1, c1).first
      e2 = self.entities.where('name = ? OR iri = ?', c2, c2).first

      CEdge.create!(child_id: categorify(e1).id, parent_id: categorify(e2).id)
    end
  end


  protected

  def categorify(entity)
    return if entity.kind != 'Class'
    Category.where(name: entity.display_name || entity.name).
      first_or_create!
  end

end
