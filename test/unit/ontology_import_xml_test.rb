require 'test_helper'

class OntologyImportXMLTest < ActiveSupport::TestCase

  context 'Import single Ontology' do
    setup do
      @user = FactoryGirl.create :user
      @ontology = FactoryGirl.create :single_ontology
      @ontology.import_xml_from_file fixture_file('test1.xml'),
        fixture_file('test1.pp.xml'), @user
    end

    should 'save logic' do
      assert_equal 'CASL', @ontology.logic.try(:name)
    end

    context 'entity count' do
      should 'be correct' do
        count = @ontology.entities.count
        assert_equal 2, count
        assert_equal count, @ontology.entities_count
      end
    end

    context 'sentence count' do
      should 'be correct' do
        count = @ontology.sentences.count
        assert_equal 1, count
        assert_equal count, @ontology.sentences_count
      end
    end
  end
  
  context 'Import distributed Ontology' do
    setup do
      @user = FactoryGirl.create :user
      @ontology = FactoryGirl.create :distributed_ontology
      @ontology.import_xml_from_file fixture_file('test2.xml'),
        fixture_file('test2.pp.xml'), @user
    end
    
    should 'create single ontologies' do
      assert_equal 4, SingleOntology.count
    end
    
    should 'have children ontologies' do
      assert_equal 4, @ontology.children.count
    end
    
    should 'have correct link count' do
      assert_equal 3, @ontology.links.count
    end
    
    should 'have no logic' do
      assert_nil @ontology.logic.try(:name)
    end
    
    should 'have no entities' do
      assert_equal 0, @ontology.entities.count
    end
    
    should 'have no sentences' do
      assert_equal 0, @ontology.sentences.count
    end
    
    context 'first child ontology' do
      setup do
        @child = @ontology.children.where(name: 'sp__E1').first
      end
      
      should 'have entities' do
        assert_equal 2, @child.entities.count
      end
      
      should 'have sentences' do
        assert_equal 1, @child.sentences.count
      end
    end

    context 'all child ontologies' do
      should 'have the same state as the parent' do
        @ontology.children.each do |c|
          assert_equal @ontology.state, c.state
        end
      end
    end
  end

  context 'Import another distributed Ontology' do
    setup do
      @user = FactoryGirl.create :user
      @ontology = FactoryGirl.create :distributed_ontology
      @ontology.import_xml_from_file fixture_file('align.xml'),
        fixture_file('align.pp.xml'), @user
      @combined = @ontology.children.where(name: 'VAlignedOntology').first
    end
    
    should 'create single ontologies' do
      assert_equal 4, SingleOntology.count
    end

    should 'create combined ontology' do
      assert @combined
    end

    context 'kinds' do
      setup do
        @kinds = @combined.entities.map(&:kind)
      end

      should 'be assigned to symbols of combined ontology' do
        assert !(@kinds.include? 'Undefined'), 'There are undefined kinds.'
      end
    end
  end

end
