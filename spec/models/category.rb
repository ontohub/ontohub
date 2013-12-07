require 'spec_helper'

describe Category do


  context "get ontologies of a category and subcategories" do
   before{ edge = FactoryGirl.create(:c_edge)
      onto1 = FactoryGirl.create(:ontology)
      onto2 = FactoryGirl.create(:ontology)
      onto1.categories = [Category.find(edge.parent_id)]
      onto1.save!
      onto2.categories = [Category.find(edge.child_id)]
      onto2.save!
      @parent_category = Category.find(edge.parent_id)
      @child_category = Category.find(edge.child_id)

    }
    it{
      @parent_category.related_ontologies.count.should == 2
      }
    it{
      @child_category.related_ontologies.count.should == 1
      }
  end

end
