require 'spec_helper'

describe Category do

  context 'Migrations' do
    it { should have_db_column('name').of_type(:text) }
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

    it 'parent ontology should have 2 related ontologies' do
      @parent_category.related_ontologies.count.should == 2
    end

    it 'child ontology should have 1 related ontology' do
      @child_category.related_ontologies.count.should == 1
    end
  end

  context 'creation of categories from ontology' do
    before do
      @user = create :user
      @ontology = create :single_ontology
      parse_this(@user, @ontology, fixture_file('Domain_Fields_Core.xml'), fixture_file('Domain_Fields_Core.pp.xml'))
      @ontology.create_categories
    end

    it 'should be the correct categories count' do
      Category.count.should == 123
    end

    it 'should be the correct category edges count' do
      CEdge.count.should == 122
    end
  end

end
