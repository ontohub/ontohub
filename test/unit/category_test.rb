require 'test_helper'

class CategoryTest < ActiveSupport::TestCase

  context 'Migrations' do
    should have_db_column('name').of_type(:text)
  end

  test 'fixme' do
    pending 'Please fix me'
  end
=begin

  context 'Validations' do
    setup do
      FactoryGirl.create :category, name: 'node1', parent: FactoryGirl.create(:category, name: 'root')
    end
    should 'trigger when identical node is created' do
      assert_raise(ActiveRecord::RecordInvalid) { FactoryGirl.create :category, name: 'node1', parent: Category.find_by_name('root') }
    end
    should 'let identical name but different ancestry (nil) pass' do
      assert_nothing_raised { FactoryGirl.create :category, name: 'node1' }
    end
    should 'let different name but identical ancestry pass' do
      assert_nothing_raised { FactoryGirl.create :category, name: 'node2', parent: Category.find_by_name('root') }
    end
  end

  context 'extracting names from sentences' do
    setup do
      @ontology = FactoryGirl.create :ontology
      @ontology.entities.push(FactoryGirl.create :entity, :kind => 'Class', :name => "Business_and_administration")
      @ontology.entities.push(FactoryGirl.create :entity, :kind => 'Class', :name => "Accounting_and_taxation")
      sentence = FactoryGirl.create :sentence, :of_meta_ontology
      @ontology.logic = FactoryGirl.create :logic, :name => 'OWL2', :user => (FactoryGirl.create :user)
      sentence.ontology = @ontology
      sentence.save!
      @ontology.save!
      @ontology.create_categories
    end

    should 'write fragments to database' do
      assert_not_nil Category.find_by_name("Business_and_administration")
      assert_not_nil Category.find_by_name("Accounting_and_taxation")
    end

    should 'have proper ancestry relationship' do
      assert Category.find_by_name("Accounting_and_taxation").parent == Category.find_by_name("Business_and_administration")
    end

    context 'a non-OWL2 ontology' do
      setup do
        @ontology.logic.name = "CASL"
      end
      should 'raise an exception' do
        assert_raise(Exception) { @ontology.create_categories }
      end
    end
  end
=end
end
