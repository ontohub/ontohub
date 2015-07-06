require 'spec_helper'

describe Category do

  context 'Migrations' do
    it { expect(subject).to have_db_column('name').of_type(:text) }
  end

  context 'get ontologies of a category and subcategories' do
    before do
      edge = create(:c_edge)

      onto1 = create(:ontology)
      onto2 = create(:ontology)

      onto1.categories = [Category.find(edge.parent_id)]
      onto1.save!

      onto2.categories = [Category.find(edge.child_id)]
      onto2.save!

      @parent_category = Category.find(edge.parent_id)
      @child_category = Category.find(edge.child_id)
    end

    it 'parent ontology expect(subject).to have 2 related ontologies' do
      expect(@parent_category.related_ontologies.count).to eq(2)
    end

    it 'child ontology expect(subject).to have 1 related ontology' do
      expect(@child_category.related_ontologies.count).to eq(1)
    end
  end

  context 'creation of categories from ontology' do
    before do
      @user = create :user
      @ontology = create :single_ontology
      parse_ontology(@user, @ontology, 'owl/Domain_Fields_Core.owl')
      @ontology.create_categories
    end

    it 'should be the correct categories count' do
      expect(Category.count).to eq(123)
    end

    it 'should be the correct category edges count' do
      expect(CEdge.count).to eq(122)
    end
  end

end
