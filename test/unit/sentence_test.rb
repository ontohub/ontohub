require 'test_helper'

class SentenceTest < ActiveSupport::TestCase

  context 'Migrations' do
    %w( ontology_id comments_count ).each do |column|
      should have_db_column(column).of_type(:integer)
    end   
  
    %w( name range ).each do |column|
      should have_db_column(column).of_type(:string)
    end

    should have_db_column('text').of_type(:text)

    should have_db_index([:ontology_id, :text]).unique(true)
    should have_db_index([:ontology_id, :kind])
  end

  context 'Associations' do
    should belong_to :ontology
    should have_and_belong_to_many :entities
  end

  context 'OntologyInstance' do
  	setup do
  		@ontology = Factory :single_ontology
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
  end

end
