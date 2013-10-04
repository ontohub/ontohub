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
        @ontology.import_xml_from_file Rails.root + 'test/fixtures/ontologies/xml/generations.xml', user
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

end
