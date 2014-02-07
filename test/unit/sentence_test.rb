require 'test_helper'

class SentenceTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( ontology_id comments_count ).each do |column|
      should have_db_column(column).of_type(:integer)
    end   
  
    %w( name range ).each do |column|
      should have_db_column(column).of_type(:string)
    end

    %w( text display_text ).each do |column|
      should have_db_column(column).of_type(:text)
    end

    should have_db_index([:ontology_id, :id]).unique(true)
    should have_db_index([:ontology_id, :name]).unique(true)
  end

  context 'Associations' do
    should belong_to :ontology
    should have_and_belong_to_many :entities
  end

  context 'OntologyInstance' do
  	setup do
  		@ontology = FactoryGirl.create :single_ontology
  	end

  	context 'creating Sentences' do
  		setup do
	  		@sentence_hash = {
	  			'name' => '... (if exists)',
          'range' => 'Examples/Reichel:40.9'
	  		}

	      @ontology.sentences.update_or_create_from_hash @sentence_hash
  		end

  		context 'correct attribute' do
  			setup do
  				@sentence = @ontology.sentences.first
  			end

  			%w[name range].each do |attr|
  				should "be #{attr}" do
  					assert_equal @sentence_hash[attr], eval("@sentence.#{attr}")
  				end
  			end
  		end
  	end

  	context 'OWL2 sentences' do
      setup do
        @ontology = FactoryGirl.create :single_ontology
        user = FactoryGirl.create :user
        @ontology.import_xml_from_file fixture_file('generations.xml'),
          fixture_file('generations.pp.xml'),
          user
        @sentence = @ontology.sentences.first
      end

      should 'have display_text set' do
        assert_not_nil @sentence.display_text
      end

      should "not contain entities' iris" do
        @sentence.entities.each do |x|
          assert !(@sentence.display_text.include? x.iri)
        end
      end
    end
  end

  context 'extracted names' do
    setup do
      sentence = FactoryGirl.create :sentence, :of_meta_ontology
      @name1,@name2 = sentence.hierarchical_class_names
    end
    should "match iris\' fragments" do
      assert_equal 'https://github.com/ontohub/OOR_Ontohub_API/blob/master/Domain_fields.owl#Accounting_and_taxation',     @name1
      assert_equal 'https://github.com/ontohub/OOR_Ontohub_API/blob/master/Domain_fields.owl#Business_and_administration', @name2
    end
  end

end
