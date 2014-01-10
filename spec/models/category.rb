require 'spec_helper'

describe Category do

  context 'get ontologies of a category and subcategories' do
    before do
      edge = FactoryGirl.create(:c_edge)

      onto1 = FactoryGirl.create(:ontology)
      onto2 = FactoryGirl.create(:ontology)

      onto1.categories = [Category.find(edge.parent_id)]
      onto1.save!

      onto2.categories = [Category.find(edge.child_id)]
      onto2.save!

      @parent_category = Category.find(edge.parent_id)
      @child_category = Category.find(edge.child_id)
    end

    it do
      @parent_category.related_ontologies.count.should == 2
    end

    it do
      @child_category.related_ontologies.count.should == 1
    end
  end

  context 'creation of categories from ontology' do
    before do
      @user = FactoryGirl.create :user
      @ontology = FactoryGirl.create :single_ontology
      @ontology.import_xml_from_file fixture_file('Domain_Fields_Core.xml'),
        fixture_file('Domain_Fields_Core.pp.xml'), @user
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
