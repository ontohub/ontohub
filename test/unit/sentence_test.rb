require 'test_helper'

class SentenceTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :ontology_version
    should have_and_belong_to_many :entities
  end

  context 'OntologyInstance' do
  	setup do
  		@ontology_version = Factory :ontology_version
  	end

  	context 'creating Sentences' do
  		setup do
	  		@sentence_hash = {
	  			'name' => '... (if exists)',
          'range' => 'Examples/Reichel:40.9'
	  		}

	      @ontology_version.sentences.update_or_create_from_hash @sentence_hash
  		end

  		context 'correct attribute' do
  			setup do
  				@sentence = @ontology_version.sentences.first
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
